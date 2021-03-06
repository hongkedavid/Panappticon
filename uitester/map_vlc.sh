tid=6620
file="nexus4.vlc.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid

cat $file | grep UI_INPUT | grep "pid\":$tid," > nexus4.vlc.ui

# Extract relevant intervals and compute resource features  
k=1
for line in $(cat tmp.mainthread); 
do 
    a=$(echo $line | cut -d',' -f2); 
    b=$(echo $line | cut -d',' -f3); 
    c=$(echo $line | cut -d',' -f1)
    s=$(($(($a*1000000))+$b))
    b=$(cat vlc.latency.tmp | head -n$k | tail -n1 | cut -f3)
    e=$(($(($s+$(($b*1000))))/1000000))    
    echo $a, $e
    rm trace.$c
    for ((i=$a;i<=$e;i=i+1)); do cat nexus4.vlc.decoded | grep "sec\":$i," >> trace.$c; done
    ./sort_json.sh trace.$c
    mv sorted.trace.$c trace.$c
    k=$(($k+1))
done

for a in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
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
