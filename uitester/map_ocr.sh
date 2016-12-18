s=""; for f in $(ls *.tracedump | cut -d'.' -f1 | sort | uniq); do s=$(echo "$s""$f):\|"); done; s=$(echo "$s""MonkeyStub")
cat ocr.logcat | grep "$s" | grep "TouchEvent\|MonkeyStub\|StartProgress\|StopProgress" | grep LinearLayout > ocr.logcat.out 
lc=$(cat ocr.logcat.out | wc -l)
for ((i=1;i<=$lc;i=i+3)); do cat ocr.logcat.out | head -n$i | tail -n1 | cut -d' ' -f2 >> tmp.1; done
for ((i=3;i<=$lc;i=i+3)); do cat ocr.logcat.out | head -n$i | tail -n1 | cut -d' ' -f2 >> tmp.2; done
paste -d' ' tmp.1 tmp.2 > tmp.3 
sed 's/://g' tmp.3 > tmp.4; sed 's/\.//g' tmp.4 > tmp.3
awk '{print ($2-$1)}' tmp.3 > tmp.4 
paste tmp.1 tmp.2 tmp.4 > ocr.latency 
rm tmp.1 tmp.2 tmp.3 tmp.4

# In case Traceview causes update to hang
for f in $(ls *.traceview); do i=$(echo $f | cut -d'.' -f2); a=$(cat $f | grep performClick | head -n1 | cut -c17-25 | sed 's/ //g'); b=$(cat $f | grep  "MainActivity\$16.doInBackground" | tail -n1 | cut -c17-25 | sed 's/ //g'); echo "$i $(($b-$a))"; done | sort -n -k1 | sed 's/ /,/g' > ocr.latency


tid=2763
file="nexus4.kernel.ocr.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
sed -i 's/AsyncTask #/AsyncTask#/g' thread_name.out
cat $file | grep FORK | grep ",\"tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid


# Map nativeRecognize thread in Nexus 4
