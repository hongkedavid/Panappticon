#adb shell setprop dalvik.vm.extra-opts -Xprofile:dualclock

# Launch Android Device Monitor
monitor

# Alternatively, run traceview from command
adb shell am profile com.example.app profile start /sdcard/trace_file
adb shell am profile com.example.app profile stop

dmtracedump -o $1.trace > $1.dump
dmtracedump -o -g $1.png $1.trace > $1.profile
