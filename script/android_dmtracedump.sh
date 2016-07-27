adb shell setprop dalvik.vm.extra-opts -Xprofile:dualclock
monitor

dmtracedump -o $1.trace > $1.dump
dmtracedump -o -g $1.png $1.trace > $1.profile
