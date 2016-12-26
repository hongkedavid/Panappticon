s=""; for f in $(cat ocr.logcat | grep offline | grep triggerGlo | cut -d'(' -f2 | cut -d')' -f1 | sed 's/ //g' | sort | uniq); do s=$(echo "$s""$f):\|"); done; s=$(echo "$s""MonkeyStub")
cat ocr.logcat | grep "$s" | grep "TouchEvent\|MonkeyStub\|StartProgress\|StopProgress" | grep LinearLayout > ocr.logcat.out 
lc=$(cat ocr.logcat.out | wc -l)
for ((i=1;i<=$lc;i=i+3)); do cat ocr.logcat.out | head -n$i | tail -n1 | cut -d' ' -f2 >> tmp.1; done
for ((i=3;i<=$lc;i=i+3)); do cat ocr.logcat.out | head -n$i | tail -n1 | cut -d' ' -f2 >> tmp.2; done
paste -d' ' tmp.1 tmp.2 > tmp.3 
sed 's/://g' tmp.3 > tmp.4; sed 's/\.//g' tmp.4 > tmp.3
awk '{print ($2-$1)}' tmp.3 > tmp.4 
paste tmp.1 tmp.2 tmp.4 > ocr.latency 
rm tmp.1 tmp.2 tmp.3 tmp.4


# Sort tracedump files by create time
ls -ltU /var/folders/47/1v76mm497qvd1dkkm32bdvpm0000gn/T/ddms* | grep "Dec 22" | cut -d'/' -f7 > traceview.info 
tid=1852
c=$(cat traceview.info | wc -l); for f in $(cat traceview.info); do ./dmtracedump -o $f > $tid.$c.traceview; c=$(($c-1)); done 
# In case Traceview causes update to hang
for f in $(ls *.traceview); 
do 
    i=$(echo $f | cut -d'.' -f2) 
    a=$(cat $f | grep performClick | head -n1 | cut -c17-25 | sed 's/ //g')
    if [ ! $a ]; then continue; fi
    b=$(cat $f | grep  "MainActivity\$16.doInBackground" | tail -n1 | cut -c17-25 | sed 's/ //g')
    echo "$i $(($b-$a))"
done | sort -n -k1 | sed 's/ /,/g' > ocr.latency


tid=1852
file="nexus4.kernel.ocr.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
sed -i 's/AsyncTask #/AsyncTask#/g' thread_name.out
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid


# Map nativeRecognize thread in Nexus 4
for a in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do
    file=$(ls $tid.$a.*traceview)
    ttid=$(cat $file | grep "nativeRecognize" | head -n1 | cut -d' ' -f1)
    ttime=$(cat $file | grep "nativeRecognize" | head -n1 | cut -c17-25 | sed 's/ //g')
    tname=$(cat $file | grep "$ttid " | head -n1 | cut -d' ' -f2- | sed 's/ //g')
    echo "$a,$tname"
done > asynctask.thread.map

cat thread_name.out | grep "AsyncTask" > asynctask.thread
for line in $(cat asynctask.thread); 
do 
     t=$(echo $line | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1) 
     sec=$(echo $line | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
     if [ $(cat fork.tid | grep "{\"pid\":$t," | grep $sec | wc -l) -gt 0 ]; then 
         echo $line
     fi
done > asynctask.thread.tmp
mv asynctask.thread.tmp asynctask.thread

for i in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do 
    line=$(cat nexus4.ocr.ui | head -n$i | tail -n1)
    sec=$(echo $line | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
    usec=$(echo $line | cut -d'{' -f3 | cut -d':' -f3 | cut -d'}' -f1) 
    t=$(cat ocr.latency | head -n$i | tail -n1 | cut -d' ' -f2)
    etime=$(($(($sec*1000000))+$usec+$t))
    end_sec=$(($etime/1000000))
    end_usec=$(($etime%1000000))
    rm trace.$i
    for ((c=$sec;c<=$end_sec;c=c+1)); do cat nexus4.ocr.decoded | grep "sec\":$c," >> trace.$i; done
    ./sort_json.sh trace.$i
    mv sorted.trace.$i trace.$i 
    init=$(cat $tid.$i.*traceview | grep performClick | head -n1 | cut -c17-25 | sed 's/ //g')
    start=$(cat $tid.$i.*traceview | grep nativeRecognize | head -n1 | cut -c17-25 | sed 's/ //g')
    end=$(cat $tid.$i.*traceview | grep nativeRecognize | tail -n1 | cut -c17-25 | sed 's/ //g')
    ptname=$(cat asynctask.thread.map | head -n$i | tail -n1 | cut -d',' -f2)
    ptid=$(cat asynctask.thread | grep "$ptname" | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1)
    cat trace.$i | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > tmp.trace
    etime=$(($(($sec*1000000))+$usec+$start-$init))
    sec1=$(($etime/1000000))
    usec1=$(($etime%1000000))
    etime=$(($(($sec*1000000))+$usec+$end-$init))
    sec2=$(($etime/1000000))
    usec2=$(($etime%1000000))
    cat tmp.trace | python GrepTrace.py $sec1 $usec1 $sec2 $usec2 > recognize.$i
    ./profile_resource.sh recognize.$i
    cat recognize.$i.cpu | python extractCPUResource.py $ptid >> $i.cpu_stat
    cat recognize.$i.sock | python extractIOResource.py $ptid >> $i.sock_stat
    cat recognize.$i.disk | python extractIOResource.py $ptid >> $i.disk_stat
    for l in $(cat recognize.$i | grep FORK | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1);
    do 
        a=$(cat trace.$i | grep "pid\":$l,\|new\":$l,\|pid\":$l}}" | head -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
        b=$(cat trace.$i | grep "pid\":$l,\|new\":$l,\|pid\":$l}}" | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
        if [ $(($b-$a)) -gt 3 ]; then
            cat trace.$i | grep "pid\":$l,\|new\":$l,\|pid\":$l}}" > tmp.trace
            cat tmp.trace | python GrepTrace.py $sec1 $usec1 $sec2 $usec2 > fork_recognize.$i
            ./profile_resource.sh fork_recognize.$i
            cat fork_recognize.$i.cpu | python extractCPUResource.py $l >> $i.cpu_stat
            cat fork_recognize.$i.sock | python extractIOResource.py $l >> $i.sock_stat
            cat fork_recognize.$i.disk | python extractIOResource.py $l >> $i.disk_stat
        fi
    done
done
rm tmp.trace
rm resource.csv
for t in $(cat ocr.latency | cut -d' ' -f1);
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


for i in $(ls $tid.*traceview | cut -d'.' -f2 | sort -n); 
do 
    for l in $(cat recognize.$i | grep FORK | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1);
    do 
        a=$(cat trace.$i | grep "pid\":$l,\|new\":$l,\|pid\":$l}}" | head -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
        b=$(cat trace.$i | grep "pid\":$l,\|new\":$l,\|pid\":$l}}" | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
        if [ $(($b-$a)) -gt 3 ]; then
            echo $i, $l
        fi
    done
done
        
