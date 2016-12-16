adb shell 
su
tcpdump -i wlan0 -w /sdcard/uber.tcpdump &
logcat -v time -f /sdcard/uber.logcat &

cat uber.logcat | grep "TouchEvent\|Monkey\|triggerGloba" | grep "TouchEvent\|Monkey\|uber" > uber.logcat.out
for i in $(grep -n "tap 705 1160" uber.logcat.out | cut -d':' -f1); do cat uber.logcat.out | head -n$(($i+1)) | tail -n1; done | cut -d' ' -f2 > tmp.1
for i in $(grep -n "tap 560 1900" uber.logcat.out | cut -d':' -f1); do cat uber.logcat.out | head -n$(($i-1)) | tail -n1; done | cut -d' ' -f2 > tmp.2
paste -d' ' tmp.1 tmp.2 > tmp.3
sed 's/://g' tmp.3 > tmp.4; sed 's/\.//g' tmp.4 > tmp.3
awk '{print ($2-$1)}' tmp.3 > tmp.4 
paste tmp.1 tmp.2 tmp.4 > uber.launch_latency

for i in $(grep -n "tap 560 1900" uber.logcat.out | cut -d':' -f1); do cat uber.logcat.out | head -n$(($i+1)) | tail -n1; done | cut -d' ' -f2 > tmp.1
for i in $(grep -n "press KEYCODE_APP_SWITCH" uber.logcat.out | cut -d':' -f1); do cat uber.logcat.out | head -n$(($i-1)) | tail -n1; done | cut -d' ' -f2 > tmp.2
paste -d' ' tmp.1 tmp.2 > tmp.3
sed 's/://g' tmp.3 > tmp.4; sed 's/\.//g' tmp.4 > tmp.3
awk '{print ($2-$1)}' tmp.3 > tmp.4 
paste tmp.1 tmp.2 tmp.4 > uber.pick_latency
rm tmp.1 tmp.2 tmp.3 tmp.4

