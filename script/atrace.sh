# enable sched, binder event tracing
echo 1 > /sys/kernel/debug/tracing/events/sched/enable
echo 1 > /sys/kernel/debug/tracing/events/binder/enable

# enable tracing all in atrace
echo 1 > /sys/kernel/debug/tracing/events/enable 

# start tracing for 10 sec
atrace -t 10 > /sdcard/atrace.dump
