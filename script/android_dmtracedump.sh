#adb shell setprop dalvik.vm.extra-opts -Xprofile:dualclock

# Launch Android Device Monitor
monitor

# Alternatively, run traceview from command
adb shell rm /sdcard/$file
adb shell am profile start $pid /sdcard/$file; adb shell date
adb shell am profile stop $pid; adb shell date

dmtracedump -o $1.trace > $1.dump
dmtracedump -o -g $1.png $1.trace > $1.profile
