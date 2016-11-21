# Collect traces from device
adb pull /sdcard/logcat.out .
adb shell ls /sdcard/$tid.*.tracedump | tr '\r' ' ' | xargs -n1 adb pull
adb pull /sdcard/$tid.tcpdump .

# Parse method and OS trace
./parse_event.sh
