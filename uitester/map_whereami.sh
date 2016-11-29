tid=1793

file="nexus4.kernel.whereami.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid


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

cat nexus4.user.whereami.decoded | grep UI_INPUT > nexus4.whereami.ui
./sort_json.sh nexus4.whereami.ui
mv sorted.nexus4.whereami.ui nexus4.whereami.ui 

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
