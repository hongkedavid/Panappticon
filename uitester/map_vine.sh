tid=3619
file="sorted.nexus4.vine.decoded"
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
cat $file | grep THREAD > thread_name.out


k=1
for line in $(cat sorted.nexus4.vine.ui); 
do 
    a=$(echo $line | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1); 
    b=$(echo $line | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1); 
    s=$(($(($a*1000000))+$b))
    b=$(cat vine.latency | head -n$k | tail -n1 | cut -f6)
    c=$k
    e=$(($(($s+$(($b*1000))))/1000000))    
    echo $a, $e
    rm trace.$c
    for ((i=$a;i<=$e;i=i+1)); do cat sorted.nexus4.vine.decoded | grep "sec\":$i," >> trace.$c; done
    k=$(($k+1))
done

# Extract relevant thread
for a in $(ls trace_view*.dump | cut -d'_' -f3  | cut -d'.' -f1 | sort -n); 
do
    if [ ! -e trace.$a ]; then continue; fi
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
