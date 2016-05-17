# source code of atrace at http://androidxref.com/4.4.4_r1/xref/frameworks/native/cmds/atrace/atrace.cpp for Android 4.4.4 KitKat

# start tracing for 10 sec with buffer size 100MB (2MB by default)
su 
echo 1 > /sys/kernel/debug/tracing/events/enable 
atrace -t 25 -b 102400 > /sdcard/atrace.dump &

# enable tracing all in atrace
echo 1 > /sys/kernel/debug/tracing/events/enable 

# dump trace
cat /sys/kernel/debug/tracing/trace > /sdcard/atrace.dump

# disable tracing all in atrace
echo 0 > /sys/kernel/debug/tracing/events/enable 

# enable sched, binder event tracing
#echo 1 > /sys/kernel/debug/tracing/events/sched/enable
#echo 1 > /sys/kernel/debug/tracing/events/binder/enable
