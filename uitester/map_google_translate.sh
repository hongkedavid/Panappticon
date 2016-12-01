tid=3203
func="SSL_read"
for f in $(ls $tid.*traceview); 
do 
     echo $f; 
     for tid in $(cat $f | grep "$func" | cut -d' ' -f1 | sort -n | uniq); 
     do 
         cat $f | grep "$tid " | head -n1; 
     done; 
done 

# Extract relevant threads
file="nexus4.translate.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
cat $file | grep FORK | grep "tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid

for f in $(ls $tid.*traceview); 
do 
    n1=$(echo $f | cut -d'.' -f2)
    tname=$(grep S3LibThread $f | grep -v S3LibThread-4 | head -n1 | tail -n1 | cut -d' ' -f2); 
    l=$(grep -n "$tname\"" thread_name.out | head -n1); c1=$(echo $l | cut -d':' -f1); 
    t=$(echo $l | cut -d':' -f5 | cut -d',' -f1); 
    for ((i=10;i<=15;i=i+1)); 
    do 
        if [ $(grep -n "$(($t+$i))" thread_name.out | wc -l) -gt 0 ]; then 
            c2=$(grep -n "$(($t+$i))" thread_name.out | head -n1 | cut -d':' -f1); 
            break; 
        fi;
    done
    echo $f
    j=1
    rm javacron.tid
    for l in $(cat $f | grep JavaCron | cut -d' ' -f1); 
    do 
        if [ ! -e $l.$n1.out ]; then continue; fi
        tt=$(cat thread_name.out | head -n$c2 | tail -n$(($c2-$c1)) | grep "pool\-" | grep "thread\-\"\|thread\"" | head -n$j | tail -n1);
        echo "$l $(cat $f | grep "$l ent" | head -n1 | cut -c18-25)" >> javacron.tid;
    done
    rm ssl.thread.$(echo $f | cut -d'.' -f2) 
    for l in $(sort -n -k2 javacron.tid | sed 's/ /,/g');
    do
        tt=$(cat thread_name.out | head -n$c2 | tail -n$(($c2-$c1)) | grep "pool\-" | grep "thread\-\"\|thread\"" | head -n$j | tail -n1);
        ttid=$(echo $tt | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1);
        start_sec=$(echo $tt | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1);
        start_usec=$(echo $tt | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1);
        echo "$(echo $l | cut -d',' -f1),$(echo $l | cut -d',' -f2),$ttid,$start_sec,$start_usec" >> ssl.thread.$(echo $f | cut -d'.' -f2) 
        j=$(($j+1))
    done; 
done
rm javacron.tid

# Extract relevant intervals and compute resource features  
for f in $(ls ssl.thread.*);
do
    i=$(echo $f | cut -d'.' -f3)
    rm $i.cpu_stat $i.sock_stat $i.disk_stat
    for line in $(cat $f);
    do
        t=$(echo $line | cut -d',' -f1)
        start=$(echo $line | cut -d',' -f2)
        ptid=$(echo $line | cut -d',' -f3)
        psec=$(echo $line | cut -d',' -f4)
        pusec=$(echo $line | cut -d',' -f5)
        trange=$(echo $psec | cut -c1-7);
        echo $t, $start, $ptid, $psec, $pusec
        cat nexus4.kernel.translate.decoded | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" | grep "sec\":$trange" > tmp.trace
        ./sort_json.sh tmp.trace
        mv sorted.tmp.trace tmp.trace
        cat $t.$i.out | grep SSL_read | grep "$t ent" | cut -c18-25 > tmp.1
        cat $t.$i.out | grep SSL_read | grep "$t xit" | cut -c18-25 > tmp.2
        paste -d',' tmp.1 tmp.2 > tmp.3
        for l in $(cat tmp.3);
        do
            s=$(echo $l | cut -d',' -f1)
            e=$(echo $l | cut -d',' -f2)
            s1=$(($(($(($psec*1000000))+$pusec+$s-$start))/1000000))
            s2=$(($(($(($psec*1000000))+$pusec+$s-$start))%1000000))
            e1=$(($(($(($psec*1000000))+$pusec+$e-$start))/1000000))
            e2=$(($(($(($psec*1000000))+$pusec+$e-$start))%1000000))
            cat tmp.trace | python GrepTrace.py $s1 $s2 $e1 $e2 > sslthread.$i
            ./profile_resource.sh sslthread.$i
           cat sslthread.$i.cpu | python extractCPUResource.py $ptid >> $i.cpu_stat
           cat sslthread.$i.sock | python extractIOResource.py $ptid >> $i.sock_stat
           cat sslthread.$i.disk | python extractIOResource.py $ptid >> $i.disk_stat
        done
    done
done
for t in $(ls ssl.thread.* | cut -d'.' -f3 | sort -n);
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
                                          
