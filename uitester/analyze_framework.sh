# Collect traces from device
adb pull /sdcard/logcat.out .
adb shell ls /sdcard/$tid.*.tracedump | tr '\r' ' ' | xargs -n1 adb pull
adb pull /sdcard/$tid.tcpdump .

# Collect traces from remote server
mkdir user 
mkdir kernel

# Get lantecy data
cat logcat | grep "$tid): triggerGl\|translateCommand" > $tid.logcat.out
cut -d' ' -f2 $tid.logcat.out > tmp.1
cut -d':' -f4 $tid.logcat.out | cut -d' ' -f2 > tmp.2
paste -d',' tmp.1 tmp.2 > tmp.3

for i in $(ls $tid.*.tracedump | cut -d'.' -f2 | sort -n); do echo $i >> tmp; done
cut -d' ' -f3 $tid.logcat.stat > tmp.1
paste -d' ' tmp tmp.1 > $tid.latency
rm tmp tmp.1

# Parse method and OS trace
./parse_event.sh

# Select top-k methods to extract method features for DT learning
for f in $(ls *.traceview); do a=$(echo $f | cut -d'.' -f2); b=$(echo $f | cut -d'.' -f1); ./extract_method.sh $a $b; done
i=1; for f in $(cut -d' ' -f3 *.stat); do echo "$i $f" >> latency; i=$(($i+1)); done
./get_topk_all_method.sh $k
echo -n "label" > feature.meta; for l in $(cat method_all_feature.meta); do echo -n ",$l" >> feature.meta; done
for l in $(cut -d' ' -f3 *.stat); do if [ $l -gt $thres ]; then echo "-1" >> tmp; else echo "+1" >> tmp; fi; done
paste tmp method_all_feature.val > dtree.csv
sed 's/\t//g' dtree.csv > dtree.csv.tmp
mv dtree.csv.tmp dtree.csv
python dtree.py dtree.csv

# Suited for inner methods
for f in $(ls *.traceview); do a=$(echo $f | cut -d'.' -f2); b=$(echo $f | cut -d'.' -f1); ./extract_inner_method.sh $a $b; done
./get_topk_method.sh $k
echo -n "label" > feature.meta; for l in $(cat method_feature.meta); do echo -n ",$l" >> feature.meta; done
#for l in $(cut -d' ' -f3 *.stat); do if [ $l -gt $thres ]; then echo "-1" >> tmp; else echo "+1" >> tmp; fi; done
paste tmp method_feature.val > dtree.csv
sed 's/\t//g' dtree.csv > dtree.csv.tmp
mv dtree.csv.tmp dtree.csv
python dtree.py dtree.csv

# Analyze relevant resource factors for each critical method
paste -d' ' tmp resource.csv > resource.csv.tmp
sed 's/ /,/g' resource.csv.tmp > resource.csv
rm resource.csv.tmp
echo "label,cpu_run,cpu_wait,cpu_sleep,sock,disk" > feature.meta 
python dtree.py resource.csv
