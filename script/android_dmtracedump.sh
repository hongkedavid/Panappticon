#adb shell setprop dalvik.vm.extra-opts -Xprofile:dualclock

# Launch Android Device Monitor for method profiling of a process
monitor

# Alternatively, launch and stop method profiling of a process from command line (tracing mode by default)
adb shell rm /sdcard/$file
adb shell am profile start $pid /sdcard/$file; adb shell date
adb shell am profile stop $pid; adb shell date

# Lauch an activity with profiling from commond line 
adb shell am start -n co.vine.android/.StartActivity --start-profiler /sdcard/vine.trace; adb shell date
adb shell am profile stop $pid; adb shell date

# Parse the method trace 
dmtracedump -o $1.trace > $1.dump
dmtracedump -o -g $1.png $1.trace > $1.profile
