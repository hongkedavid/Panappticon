adb shell cat /proc/meminfo | head -n5
adb shell cat /proc/$pid/stat | cut -d " " -f 1,2,10,12
