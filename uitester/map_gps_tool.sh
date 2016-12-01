# Customized trace extraction script
for line in $(sed 's/ /,/g' gps.latency); do i=$(echo $line | cut -d',' -f1); lat=$(echo $line | cut -d',' -f2); f=$(ls *.$i.*.traceview | head -n1); t=$(echo $f | cut -d'.' -f1); ./extract_inner_method_gps.sh $i $t $lat; done
for line in $(sed 's/ /,/g' gps.latency); do i=$(echo $line | cut -d',' -f1); lat=$(echo $line | cut -d',' -f2); f=$(ls *.$i.*.traceview | head -n1); t=$(echo $f | cut -d'.' -f1); ./extract_method_gps.sh $i $t $lat; done

tid=6988

file="nexus4.kernel.gps.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid

cat nexus4.user.gps.decoded | grep UI_INPUT > nexus4.gps.ui
./sort_json.sh nexus4.gps.ui
mv sorted.nexus4.gps.ui nexus4.gps.ui 

k=1
for line in $(cat nexus4.gps.ui); 
do 
    a=$(echo $line | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1); 
    b=$(echo $line | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1); 
    s=$(($(($a*1000000))+$b))
    b=$(cat gps.latency | head -n$k | tail -n1 | cut -d' ' -f2)
    c=$(cat gps.latency | head -n$k | tail -n1 | cut -d' ' -f1)
    e=$(($(($s+$(($b*1000))))/1000000))    
    echo $a, $e
    rm trace.$c
    for ((i=$a;i<=$e;i=i+1)); do cat nexus4.gps.decoded | grep "sec\":$i," >> trace.$c; done
    ./sort_json.sh trace.$c
    mv sorted.trace.$c trace.$c
    k=$(($k+1))
done
