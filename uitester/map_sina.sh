k=1
for line in $(cat sina.timestamp | sed 's/ /,/g'); 
do 
    a=$(echo $line | cut -d',' -f1); 
    b=$(echo $line | cut -d',' -f2); 
    s=$(($(($a*1000000))+$b))
    b=$(cat sina.latency | head -n$k | tail -n1 | cut -f3)
    c=$k
    e=$(($(($s+$(($b*1000))))/1000000))    
    echo $a, $e
    rm trace.$c
    for ((i=$a;i<=$e;i=i+1)); do cat sorted.nexus4.sina.decoded | grep "sec\":$i," >> trace.$c; done
    k=$(($k+1))
done

