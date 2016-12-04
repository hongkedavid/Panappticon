tid=8171

# Extract relevant thread
func="SSL_read"
for f in $(ls $tid.*traceview); 
do
     echo $f
     a=$(echo $f | cut -d'.' -f2)
     for t in $(grep "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do 
         cat $f | grep "$t " | head -n1; 
     done
done > sslread.thread

# Get input timestamp
file="nexus4.offerup.ui"
cat nexus4.user.offerup.decoded | grep UI_INPUT > $file; ./sort_json.sh $file
for ((i=5;i<=$(cat $file | wc -l);i=i+3)); do cat $file | head -n$i | tail -n1 >> $file.tmp; done
mv $file.tmp $file

file="nexus4.kernel.offerup.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid

for a in $(ls $tid.33.*traceview | cut -d'.' -f2 | sort -n); 
do
    for f in $(cat trace.$a | grep CONTEXT | grep "\"I\"" | cut -d':' -f7 | cut -d',' -f1 | sort -nr | uniq);  
    do      
        if [ $(cat fork.tid | grep "{\"pid\":$f," | wc -l) -gt 0 ]; then     
            sec=$(cat fork.tid | grep "{\"pid\":$f," | cut -d':' -f4 | cut -d',' -f1) 
            line=$(cat thread_name.out | grep "{\"pid\":$f," | grep "$sec" | head -n1)
            ptid=$(echo $line | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1)
            tname=$(echo $line | cut -d'{' -f4 | cut -d'"' -f6)
            echo "$ptid,$a,$tname,"
        fi  
    done
done > thread.map
sed -i 's/ //g' thread.map

#########################
rm pool12.thread
for t in $(cat thread_name.out | grep "pool\-12\-thread" | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1); 
do 
    if [ $(cat fork.tid | grep "{\"pid\":$t," | wc -l) -gt 0 ]; then 
       cat thread_name.out | grep "pool\-12\-thread" | grep "{\"pid\":$t," >> pool12.thread
    fi
done

for i in $(cat trace.98 | grep CONTEXT | grep "\"I\"" | cut -d'{' -f3 | cut -d':' -f5 | cut -d',' -f1 | sort | uniq);
do 
     cat thread_name.out | grep "{\"pid\":$i," | grep "Picasso\|pool\-12\-\|Retrofit\|Apptent\|IntentService\[R"; 
done

for ((j=2;j<=102;j=j+1)); 
do 
    echo $j; 
    for i in $(cat trace.$j | grep CONTEXT | grep "\"I\"" | cut -d'{' -f3 | cut -d':' -f5 | cut -d',' -f1 | sort | uniq); 
    do 
        cat pool12.thread | grep "{\"pid\":$i," | grep "pool\-12\-"; 
    done
done

cat thread_name.out | grep "Apptentive-M" > apptent.thread
for line in $(cat apptent.thread); 
do 
     t=$(echo $line | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1) 
     if [ $(cat fork.tid | grep "{\"pid\":$t," | wc -l) -gt 0 ]; then 
         echo $line
     fi
done > apptent.thread.tmp
mv apptent.thread.tmp apptent.thread

cat thread_name.out | grep "IntentService\[R" > intent.thread
for line in $(cat intent.thread); 
do 
     t=$(echo $line | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1)
     if [ $(cat fork.tid | grep "{\"pid\":$t," | wc -l) -gt 0 ]; then 
         echo $line
     fi
done > intent.thread.tmp
mv intent.thread.tmp intent.thread

# Picasso-Idle: Thread-xxx
# Retrofit-Idle: pool-xxx-thread-xxx 
#for f in $(cat trace.10 | grep -v 1479761249 | grep CONTEXT | grep "\"I\"" | cut -d':' -f7 | cut -d',' -f1 | sort -nr | uniq); 
for f in $(cat trace.20 | grep -v 1479762443 | grep CONTEXT | grep "\"I\"" | cut -d':' -f7 | cut -d',' -f1 | sort -nr | uniq); 
do 
    if [ $(cat fork.tid | grep "{\"pid\":$f," | wc -l) -gt 0 ]; then 
       cat fork.tid | grep "{\"pid\":$f,"; cat thread_name.out | grep "{\"pid\":$f," | head -n1; 
    fi; 
done
#################################

func="SSL_read"; file="ssl.thread"
for a in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do
     f=$(ls $tid.$a.*traceview)
     rm $file.$a
     for t in $(grep -n "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do  
         ttid=$(cat $f | grep "$t " | head -n1 | cut -d' ' -f1)
         tname=$(cat $f | grep "$t " | head -n1 | sed 's/ /,/g' | cut -d',' -f2- | sed 's/,//g' | sed 's/\[/_/g')
         line=",$a,$tname"
         echo $line
         ans=""
         for l in $(cat thread.map | grep ",$a,"); 
         do
             l1=$(echo $l | cut -d',' -f2,3 | sed 's/\[/_/g')
             if [ ! $(echo $l1 | cut -d',' -f2) ]; then continue; fi
             if [ $tname = "Picasso-Idle" ] && [ $(echo $l1 | grep "Thread\-" | wc -l) -gt 0 ] && [ $(cat $f | grep "$(echo $l1 | cut -d',' -f2)" | wc -l) -eq 0 ]; then
                 echo $l1
                 if [ $(cat $file.$a | grep ",$(echo $l | cut -d',' -f1)" | wc -l) -eq 0 ]; then 
                     ans=$(echo $l | cut -d',' -f1)
                     break
                 fi
             elif [ $tname = "Retrofit-Idle" ] && [ $(echo $l1 | grep "pool\-" | wc -l) -gt 0 ] && [ $(cat $f | grep "$(echo $l1 | cut -d',' -f2)" | wc -l) -eq 0 ]; then
                 echo $l1
                 if [ $(cat $file.$a | grep ",$(echo $l | cut -d',' -f1)" | wc -l) -eq 0 ]; then 
                     ans=$(echo $l | cut -d',' -f1)
                     break
                 fi
             else
                 if [ $(echo $line | grep "$(echo $l1 | cut -d',' -f2)" | wc -l) -gt 0 ]; then
                     echo $ttid, $l1
                     ans=$(echo $l | cut -d',' -f1)
                     break
                 fi
             fi
         done
         echo "$ttid,$ans" >> $file.$a
     done
done


# Extract relevant intervals and compute resource features  
k=1
for line in $(cat nexus4.offerup.ui); 
do 
    a=$(echo $line | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1); 
    b=$(echo $line | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1); 
    s=$(($(($a*1000000))+$b))
    b=$(cat offerup.latency | head -n$k | tail -n1 | cut -d' ' -f2)
    c=$(cat offerup.latency | head -n$k | tail -n1 | cut -d' ' -f1)
    e=$(($(($(($s+$(($b*1000))))/1000000))+1))    
    echo $a, $e
    rm trace.$c
    for ((i=$a;i<=$e;i=i+1)); do cat nexus4.offerup.decoded | grep "sec\":$i," >> trace.$c; done
    ./sort_json.sh trace.$c
    mv sorted.trace.$c trace.$c
    k=$(($k+1))
done

func="SSL_read"
file="ssl.thread"
k=1
for i in $(ls $file.* | cut -d'.' -f3 | sort -n);
do
    f="$file.$i"
    rm $i.cpu_stat $i.sock_stat $i.disk_stat
    for line in $(cat $f);
    do
        t=$(echo $line | cut -d',' -f1)
        ptid=$(echo $line | cut -d',' -f2)
        start=$(grep "ActivityThread.handleLaunchActivity" 1.$i.out | head -n1 | cut -c17-25 | sed 's/ //g')
        psec=$(cat nexus4.offerup.ui | head -n$k | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
        pusec=$(cat nexus4.offerup.ui | head -n$k | tail -n1 | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1)
#        echo $t, $start, $ptid, $psec, $pusec
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
            echo $i, $t, $ptid, $s1, $s2, $e1, $e2
            cat tmp.trace | python GrepTrace.py $s1 $s2 $e1 $e2 > sslthread.$i
            if [ $(cat sslthread.$i | wc -l) -gt 0 ]; then
               fline=$(cat sslthread.$i | head -n1)
               ss1=$(echo $fline | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
               ss2=$(echo $fline | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1)
               if [ $(($(($ss1*1000000))+$ss2-$(($s1*1000000))-$s2)) -gt 0 ]; then
                  lc=$(grep -n "$fline" tmp.trace | cut -d':' -f1)
                  cat tmp.trace | head -n$(($lc-1)) | tail -n1 > sslthread.$i.tmp
                  cat sslthread.$i >> sslthread.$i.tmp
                  mv sslthread.$i.tmp sslthread.$i
               fi
               fline=$(cat sslthread.$i | tail -n1)
               ss1=$(echo $fline | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
               ss2=$(echo $fline | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1)
                if [ $(($(($e1*1000000))+$e2-$(($ss1*1000000))-$ss2)) -gt 0 ]; then
                  lc=$(grep -n "$fline" tmp.trace | cut -d':' -f1)
                  cat tmp.trace | head -n$(($lc+1)) | tail -n1 >> sslthread.$i
               fi
            fi
            cat sslthread.$i | head -n1
            cat sslthread.$i | tail -n1
            ./profile_resource.sh sslthread.$i
            cat sslthread.$i.cpu | python extractCPUResource.py $ptid >> $i.cpu_stat
            cat sslthread.$i.sock | python extractIOResource.py $ptid >> $i.sock_stat
            cat sslthread.$i.disk | python extractIOResource.py $ptid >> $i.disk_stat
        done
    done
    rm sslthread.$i*
    k=$(($k+1))
done
rm tmp.trace tmp.1 tmp.2 tmp.3
rm resource.csv
for t in $(ls $file.* | cut -d'.' -f3 | sort -n);
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
