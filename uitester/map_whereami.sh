# Label by median + std
tid=1793

file="nexus4.kernel.whereami.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid

cat nexus4.user.whereami.decoded | grep UI_INPUT > nexus4.whereami.ui
./sort_json.sh nexus4.whereami.ui
mv sorted.nexus4.whereami.ui nexus4.whereami.ui 


# Extract relevant thread
func="MessageQueue.next"
for f in $(ls $tid.*traceview); 
do
     echo $f
     a=$(echo $f | cut -d'.' -f2)
     for t in $(grep "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do 
         cat $f | grep "$t " | head -n1; 
     done
done > msgqueue.thread
for f in $(cat thread_name.out | grep "Thread\-192" | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1); 
do 
     cat fork.tid | grep "{\"pid\":$f,"; 
done > msgqueue.map

k=1
for line in $(cat nexus4.whereami.ui); 
do 
    a=$(echo $line | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1); 
    b=$(echo $line | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1); 
    s=$(($(($a*1000000))+$b))
    b=$(cat whereami.latency | head -n$k | tail -n1 | cut -d' ' -f2)
    c=$(cat whereami.latency | head -n$k | tail -n1 | cut -d' ' -f1)
    e=$(($(($(($s+$(($b*1000))))/1000000))+1))    
    echo $a, $e
    rm trace.$c
    for ((i=$a;i<=$e;i=i+1)); do cat nexus4.whereami.decoded | grep "sec\":$i," >> trace.$c; done
    ./sort_json.sh trace.$c
    mv sorted.trace.$c trace.$c
    k=$(($k+1))
done

tid=6989
s=""
for line in $(cat thread_name.out | grep Binder); 
do 
    i=$(echo $line | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1); 
    t=$(echo $line | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1); 
    if [ $(cat fork.tid | grep "{\"pid\":$i," | grep "$t" | wc -l) -gt 0 ]; then 
        if [ ! $s ]; then 
           s=$(echo "pid\":$i,");
        else 
           s=$(echo "$s\|pid\":$i,");
        fi
    fi 
done 
for i in $(cut -d' ' -f1 whereami.latency);
do 
    t=0
    cat trace.$i | grep "pid\":$tid,\|old\":$tid,\|pid\":$tid}}" > tmp.trace
    for l2 in $(cat tmp.trace | grep "pid\":$tid}}" | grep WAITQUEUE_NOTIFY | grep "$s");
    do 
        n=$(grep -n $l2 tmp.trace | cut -d':' -f1);
        if [ $n -le 1 ]; then continue; fi
        l1=$(cat tmp.trace | head -n$(($n-1)) | tail -n1);
        sec1=$(echo $l1 | cut -d'{' -f3  | cut -d':' -f2 | cut -d',' -f1)
        usec1=$(echo $l1 | cut -d'{' -f3  | cut -d':' -f3 | cut -d'}' -f1)
        sec2=$(echo $l2 | cut -d'{' -f3  | cut -d':' -f2 | cut -d',' -f1)
        usec2=$(echo $l2 | cut -d'{' -f3  | cut -d':' -f3 | cut -d'}' -f1)
        t=$(($(($(($sec2-$sec1))*1000000))+$usec2-$usec1+$t))
    done
    echo $i, $t
done > binder.stat
rm tmp.trace


# Extract relevant intervals and compute resource features  
func="MessageQueue.next"
k=1
for i in $(cat whereami.latency | cut -d' ' -f1);
do
    rm $i.cpu_stat $i.sock_stat $i.disk_stat
    t=1
    ptid=1793
    cat trace.$i | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > tmp.trace
    cat $t.$i.out | grep $func | grep "$t ent" | cut -c18-25 | sed 's/ //g' > tmp.1
    cat $t.$i.out | grep $func | grep "$t xit" | cut -c18-25 | sed 's/ //g' > tmp.2
    paste -d',' tmp.1 tmp.2 > tmp.3
    start=$(grep "PerformClick.run" $t.$i.out | head -n1 | cut -c17-25 | sed 's/ //g')
    psec=$(cat nexus4.whereami.ui | head -n$k | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
    pusec=$(cat nexus4.whereami.ui | head -n$k | tail -n1 | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1)
    echo $t, $start, $ptid, $psec, $pusec
    for l in $(cat tmp.3);
    do
        s=$(echo $l | cut -d',' -f1)
        e=$(echo $l | cut -d',' -f2)
        s1=$(($(($(($psec*1000000))+$pusec+$s-$start))/1000000))
        s2=$(($(($(($psec*1000000))+$pusec+$s-$start))%1000000))
        e1=$(($(($(($psec*1000000))+$pusec+$e-$start))/1000000))
        e2=$(($(($(($psec*1000000))+$pusec+$e-$start))%1000000))
        echo $s1, $s2, $e1, $e2
        cat tmp.trace | python GrepTrace.py $s1 $s2 $e1 $e2 > msgthread.$i
        cat msgthread.$i | head -n1
        cat msgthread.$i | tail -n1
        ./profile_resource.sh msgthread.$i
        cat msgthread.$i.cpu | python extractCPUResource.py $ptid >> $i.cpu_stat
        cat msgthread.$i.sock | python extractIOResource.py $ptid >> $i.sock_stat
        cat msgthread.$i.disk | python extractIOResource.py $ptid >> $i.disk_stat
    done
    k=$(($k+1))
    rm msgthread.$i
done
rm tmp.1 tmp.2 tmp.3 tmp.trace 
rm resource.csv
for t in $(cat whereami.latency | cut -d' ' -f1);
do
   for ((j=2;j<=4;j=j+1));
   do
        c=0;
        for f in $(cat $t.cpu_stat | cut -d' ' -f$j);
        do
            c=$(($c+$f));
        done;
        echo -n "$c " >> resource.csv;
    done;
    c=0;
    for f in $(cat $t.sock_stat | cut -d' ' -f2);
    do
        c=$(($c+$f));
    done;
    echo -n "$c " >> resource.csv;
    c=0
    for f in $(cat $t.disk_stat | cut -d' ' -f2);
    do
        c=$(($c+$f));
    done;
    echo -n "$c" >> resource.csv;
    echo "" >> resource.csv;
done
