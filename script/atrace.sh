# enable sched, binder event tracing
echo 1 > /sys/kernel/debug/tracing/events/sched/enable
echo 1 > /sys/kernel/debug/tracing/events/binder/enable

# enable tracing all in atrace
echo 1 > /sys/kernel/debug/tracing/events/enable 

# start tracing for 10 sec with buffer size 100MB (2MB by default)
atrace -t 10 -b 102400 > /sdcard/atrace.dump
