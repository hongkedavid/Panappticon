# Label by median + 2*std
tid=8579

file="nexus4.kernel.flipp.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
sed -i 's/AsyncTask #/AsyncTask#/g' thread_name.out
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid

file="nexus4.flipp.ui"
cat nexus4.user.flipp.decoded | grep UI_INPUT > $file; ./sort_json.sh $file
for ((i=1;i<=$(cat $file | wc -l);i=i+3)); do cat $file | head -n$i | tail -n1 >> $file.tmp; done
mv $file.tmp $file

# Extract relevant thread
func="SSL_read"
for a in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do
     f=$(ls $tid.$a.*traceview)
     echo $f
     for t in $(grep "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do 
         cat $f | grep "$t " | head -n1; 
     done
done > sslread.thread
sed -i 's/AsyncTask #/AsyncTask#/g' sslread.thread

func="Posix.connect"
for a in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do
     f=$(ls $tid.$a.*traceview)
     echo $f
     for t in $(grep "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do 
         cat $f | grep "$t " | head -n1; 
     done
done > connect.thread
sed -i 's/AsyncTask #/AsyncTask#/g' connect.thread

for f in $(cat sslread.thread | grep -v traceview | cut -d' ' -f2 | sort | uniq); 
do
    for a in $(cat thread_name.out | grep "$f" | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1); 
    do 
        for line in $(cat fork.tid | grep "{\"pid\":$a,"); do echo "$f:$line"; done
    done
done > sslread.map

for f in $(cat connect.thread | grep -v traceview | cut -d' ' -f2 | sort | uniq); 
do
    for a in $(cat thread_name.out | grep "$f" | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1); 
    do 
        for line in $(cat fork.tid | grep "{\"pid\":$a,"); do echo "$f:$line"; done
    done
done > connect.map

func="SSL_read"
for a in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do
     f=$(ls $tid.$a.*traceview)
     isec=$(cat nexus4.flipp.ui | head -n$a | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
     rm ssl.thread.$a
     for t in $(grep -n "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do 
         ttid=$(cat $f | grep "$t " | head -n1 | cut -d' ' -f1)
         tname=$(cat $f | grep "$t " | head -n1 | sed 's/ /,/g' | cut -d',' -f2- | sed 's/,//g')
         min_gap=10000000000
         ans=""
         for l in $(cat sslread.map | grep "$tname:");
         do
             ptsec=$(echo $l | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
             ptid=$(echo $l | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1)
             if [ $(($ptsec-$isec)) -ge 0 ] && [ $(($ptsec-$isec)) -lt 5 ]; then ans=$ptid; break; fi
             if [ $(($isec-$ptsec)) -gt 0 ] && [ $(($isec-$ptsec)) -lt $min_gap ]; then ans=$ptid; min_gap=$(($isec-$ptsec)); fi             
         done
         echo "$ttid,$ans" >> ssl.thread.$a
     done
done


func="Posix.connect"
for a in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do
     f=$(ls $tid.$a.*traceview)
     isec=$(cat nexus4.flipp.ui | head -n$a | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
     rm connect.thread.$a
     for t in $(grep -n "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do 
         ttid=$(cat $f | grep "$t " | head -n1 | cut -d' ' -f1)
         tname=$(cat $f | grep "$t " | head -n1 | sed 's/ /,/g' | cut -d',' -f2- | sed 's/,//g')
         min_gap=10000000000
         ans=""
         for l in $(cat connect.map | grep "$tname:");
         do
             ptsec=$(echo $l | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
             ptid=$(echo $l | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1)
             if [ $(($ptsec-$isec)) -ge 0 ] && [ $(($ptsec-$isec)) -lt 5 ]; then ans=$ptid; break; fi
             if [ $(($isec-$ptsec)) -gt 0 ] && [ $(($isec-$ptsec)) -lt $min_gap ]; then ans=$ptid; min_gap=$(($isec-$ptsec)); fi             
         done
         echo "$ttid,$ans" >> connect.thread.$a
     done
done


k=1
for line in $(cat nexus4.flipp.ui); 
do 
    a=$(echo $line | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1); 
    b=$(echo $line | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1); 
    s=$(($(($a*1000000))+$b))
    b=$(cat flipp.latency | head -n$k | tail -n1 | cut -d' ' -f2)
    c=$(cat flipp.latency | head -n$k | tail -n1 | cut -d' ' -f1)
    e=$(($(($s+$(($b*1000))))/1000000))    
    echo $a, $e
    rm trace.$c
    for ((i=$a;i<=$e;i=i+1)); do cat nexus4.flipp.decoded | grep "sec\":$i," >> trace.$c; done
    ./sort_json.sh trace.$c
    mv sorted.trace.$c trace.$c
    k=$(($k+1))
done


# Extract relevant intervals and compute resource features  
func="SSL_read"
k=1
for i in $(ls ssl.thread.* | cut -d'.' -f3 | sort -n);
do
    f="ssl.thread.$i"
    rm $i.cpu_stat $i.sock_stat $i.disk_stat
    for line in $(cat $f);
    do
        t=$(echo $line | cut -d',' -f1)
        ptid=$(echo $line | cut -d',' -f2)
        start=$(grep "ActivityThread.handleLaunchActivity" 1.$i.out | head -n1 | cut -c17-25 | sed 's/ //g')
        psec=$(cat nexus4.flipp.ui | head -n$k | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
        pusec=$(cat nexus4.flipp.ui | head -n$k | tail -n1 | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1)
        echo $t, $start, $ptid, $psec, $pusec
        cat trace.$i | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > tmp.trace
        cat $t.$i.out | grep $func | grep "$t ent" | cut -c18-25 | sed 's/ //g' > tmp.1
        cat $t.$i.out | grep $func | grep "$t xit" | cut -c18-25 | sed 's/ //g' > tmp.2
        paste -d',' tmp.1 tmp.2 > tmp.3
        for l in $(cat tmp.3);
        do
            s=$(echo $l | cut -d',' -f1)
            e=$(echo $l | cut -d',' -f2)
            s1=$(($(($(($psec*1000000))+$pusec+$s-$start))/1000000))
            s2=$(($(($(($psec*1000000))+$pusec+$s-$start))%1000000))
            e1=$(($(($(($psec*1000000))+$pusec+$e-$start))/1000000))
            e2=$(($(($(($psec*1000000))+$pusec+$e-$start))%1000000))
            echo $s1, $s2, $e1, $e2
            cat tmp.trace | python GrepTrace.py $s1 $s2 $e1 $e2 > sslthread.$i
            cat sslthread.$i | head -n1
            cat sslthread.$i | tail -n1
            ./profile_resource.sh sslthread.$i
            cat sslthread.$i.cpu | python extractCPUResource.py $ptid >> $i.cpu_stat
            cat sslthread.$i.sock | python extractIOResource.py $ptid >> $i.sock_stat
            cat sslthread.$i.disk | python extractIOResource.py $ptid >> $i.disk_stat
        done
    done
    rm sslthread.$i
    k=$(($k+1))
done
rm tmp.trace tmp.1 tmp.2 tmp.3
rm resource.csv
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



func="Posix.connect"
k=1
for i in $(ls connect.thread.* | cut -d'.' -f3 | sort -n);
do
    f="connect.thread.$i"
    rm $i.cpu_stat $i.sock_stat $i.disk_stat
    for line in $(cat $f);
    do
        t=$(echo $line | cut -d',' -f1)
        ptid=$(echo $line | cut -d',' -f2)
        start=$(grep "ActivityThread.handleLaunchActivity" 1.$i.out | head -n1 | cut -c17-25 | sed 's/ //g')
        psec=$(cat nexus4.flipp.ui | head -n$k | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
        pusec=$(cat nexus4.flipp.ui | head -n$k | tail -n1 | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1)
        echo $t, $start, $ptid, $psec, $pusec
        cat trace.$i | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > tmp.trace
        cat $t.$i.out | grep $func | grep "$t ent" | cut -c18-25 | sed 's/ //g' > tmp.1
        cat $t.$i.out | grep $func | grep "$t xit" | cut -c18-25 | sed 's/ //g' > tmp.2
        paste -d',' tmp.1 tmp.2 > tmp.3
        for l in $(cat tmp.3);
        do
            s=$(echo $l | cut -d',' -f1)
            e=$(echo $l | cut -d',' -f2)
            s1=$(($(($(($psec*1000000))+$pusec+$s-$start))/1000000))
            s2=$(($(($(($psec*1000000))+$pusec+$s-$start))%1000000))
            e1=$(($(($(($psec*1000000))+$pusec+$e-$start))/1000000))
            e2=$(($(($(($psec*1000000))+$pusec+$e-$start))%1000000))
            echo $s1, $s2, $e1, $e2
            cat tmp.trace | python GrepTrace.py $s1 $s2 $e1 $e2 > connectthread.$i
            cat connectthread.$i | head -n1
            cat connectthread.$i | tail -n1
            ./profile_resource.sh connectthread.$i
            cat connectthread.$i.cpu | python extractCPUResource.py $ptid >> $i.cpu_stat
            cat connectthread.$i.sock | python extractIOResource.py $ptid >> $i.sock_stat
            cat connectthread.$i.disk | python extractIOResource.py $ptid >> $i.disk_stat
        done
    done
    rm connectthread.$i
    k=$(($k+1))
done
rm tmp.trace tmp.1 tmp.2 tmp.3
rm resource.csv
for t in $(ls connect.thread.* | cut -d'.' -f3 | sort -n);
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
