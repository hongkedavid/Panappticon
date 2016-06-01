# System bootup time
adb shell cat /proc/stat | grep btime | awk '{ print $2 }'

# System uptime
adb shell cat /proc/uptime | awk '{ print $1 }'
adb shell uptime 

# First process init time
adb shell ls -ld /proc/1
