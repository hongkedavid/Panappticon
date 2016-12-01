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
     for t in $(grep "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do 
         ttid=$(cat $f | grep "$t " | head -n1 | cut -d' ' -f1)
         tname=$(cat $f | grep "$t " | head -n1 | sed 's/ /,/g' | cut -d',' -f2 | sed 's/,//g')
         min_gap=10000000000
         for l in $(cat sslread.map | grep "$tname:");
         do
             ptsec=$(echo $l | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
             ptid=$(echo $l | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1)
             if [ $(($ptsec-$isec)) -gt 0 ] && [ $(($ptsec-$isec)) -lt 5 ]; then ans=$ptid; break; fi
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
     for t in $(grep "$func" *.$a.out | cut -d':' -f1 | cut -d'.' -f1 | sort | uniq); 
     do 
         ttid=$(cat $f | grep "$t " | head -n1 | cut -d' ' -f1)
         tname=$(cat $f | grep "$t " | head -n1 | sed 's/ /,/g' | cut -d',' -f2 | sed 's/,//g')
         min_gap=10000000000
         for l in $(cat connect.map | grep "$tname:");
         do
             ptsec=$(echo $l | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
             ptid=$(echo $l | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1)
             if [ $(($ptsec-$isec)) -gt 0 ] && [ $(($ptsec-$isec)) -lt 5 ]; then ans=$ptid; break; fi
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
