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

for a in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do
    f=$(ls $tid.$a.*traceview)
    isec=$(cat nexus4.offerup.ui | head -n$a | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
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

#########################
rm pool12.thread
for t in $(cat thread_name.out | grep "pool\-12\-thread" | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1); 
do 
    if [ $(cat fork.tid | grep "{\"pid\":$t," | wc -l) -gt 0 ]; then 
       cat thread_name.out | grep "pool\-12\-thread" | grep "{\"pid\":$t," >> pool12.thread
    fi
done

for i in $(cat trace.98 | grep CONTEXT | grep "\"I\"" | cut -d'{' -f3 | cut -d':' -f5 | cut -d',' -f1 | sort | uniq); do 
cat thread_name.out | grep "{\"pid\":$i," | grep "Picasso\|pool\-12\-\|Retrofit\|Apptent\|IntentService\[R"; done

for ((j=2;j<=102;j=j+1)); do echo $j; 
for i in $(cat trace.$j | grep CONTEXT | grep "\"I\"" | cut -d'{' -f3 | cut -d':' -f5 | cut -d',' -f1 | sort | uniq); 
do cat pool12.thread | grep "{\"pid\":$i," | grep "pool\-12\-"; done; done

cat thread_name.out | grep "Apptentive-M" > apptent.thread
for line in $(cat apptent.thread); do t=$(echo $line | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1); if [ $(cat fork.tid | grep "{\"pid\":$t," | wc -l) -gt 0 ]; then echo $line; fi; done > apptent.thread.tmp
mv apptent.thread.tmp apptent.thread

cat thread_name.out | grep "IntentService\[R" > intent.thread
for line in $(cat intent.thread); do t=$(echo $line | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1); if [ $(cat fork.tid | grep "{\"pid\":$t," | wc -l) -gt 0 ]; then echo $line; fi; done > intent.thread.tmp
mv intent.thread.tmp intent.thread

# Picasso-Idle: Thread-xxx
# Retrofit-Idle: pool-xxx-thread-xxx 
for f in $(cat trace.10 | grep -v 1479761249 | grep CONTEXT | grep "\"I\"" | cut -d':' -f7 | cut -d',' -f1 | sort -nr | uniq); 
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
         for l in $(cat thread.map | grep ",$a,"); 
         do
             l1=$(echo $l | cut -d',' -f2,3 | sed 's/\[/_/g')
             if [ $(echo $line | grep "$l1" | wc -l) -gt 0 ]; then
                ans=$(echo $l | cut -d',' -f1)
             else
                ans=""
             fi
             echo "$ttid,$ans" >> $file.$a
         done
     done
done


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
