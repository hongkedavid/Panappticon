# Collect traces from device
adb pull /sdcard/logcat.out .
adb shell ls /sdcard/$tid.*.tracedump | tr '\r' ' ' | xargs -n1 adb pull
adb pull /sdcard/$tid.tcpdump .

# Collect traces from remote server
mkdir user 
mkdir kernel

# Parse method and OS trace
./parse_event.sh

# Select top-k methods to extract method features for DT learning
for f in $(ls *.traceview); do a=$(echo $f | cut -d'.' -f2); b=$(echo $f | cut -d'.' -f1); ./extract_method.sh $a $b; done
./get_topk_all_method.sh $k
echo -n "label" > feature.meta; for l in $(cat method_all_feature.meta); do echo -n ",$l" >> feature.meta; done
for l in $(cut -d' ' -f3 *.stat); do if [ $l -gt 8000 ]; then echo "-1" >> tmp; else echo "+1" >> tmp; fi; done
paste tmp method_all_feature.val > dtree.csv
sed 's/\t//g' dtree.csv > dtree.csv.tmp
mv dtree.csv.tmp dtree.csv
python dtree.py dtree.csv

# Suited for inner methods
for f in $(ls *.traceview); do a=$(echo $f | cut -d'.' -f2); b=$(echo $f | cut -d'.' -f1); ./extract_inner_method.sh $a $b; done
./get_topk_method.sh $k
echo -n "label" > feature.meta; for l in $(cat method_feature.meta); do echo -n ",$l" >> feature.meta; done
#for l in $(cut -d' ' -f3 *.stat); do if [ $l -gt 8000 ]; then echo "-1" >> tmp; else echo "+1" >> tmp; fi; done
paste tmp method_feature.val > dtree.csv
sed 's/\t//g' dtree.csv > dtree.csv.tmp
mv dtree.csv.tmp dtree.csv
python dtree.py dtree.csv

# Analyze relevant resource factors for each critical method
