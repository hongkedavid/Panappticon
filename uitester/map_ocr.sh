cat ocr.logcat | grep "$pid):\|MonkeyStub" | grep "TouchEvent\|MonkeyStub\|StartProgress\|StopProgress" | grep LinearLayout > ocr.logcat.out 
for ((i=1;i<=153;i=i+3)); do cat ocr.logcat.out | head -n$i | tail -n1 | cut -d' ' -f2 >> tmp.1; done
for ((i=3;i<=153;i=i+3)); do cat ocr.logcat.out | head -n$i | tail -n1 | cut -d' ' -f2 >> tmp.2; done
paste -d' ' tmp.1 tmp.2 > tmp.3 
sed 's/://g' tmp.3; sed 's/\.//g' tmp.3
awk '{print ($2-$1)}' tmp.3 > tmp.4 
paste tmp.1 tmp.2 tmp.4 > ocr.latency 
rm tmp.1 tmp.2 tmp.3 tmp.4

