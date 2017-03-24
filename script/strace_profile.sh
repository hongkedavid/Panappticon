# Ref: https://linux.die.net/man/1/strace and https://strace.io/ 
# Ref: http://www.brendangregg.com/blog/2014-05-11/strace-wow-much-syscall.html
# Profile CPU time (spent running in the kernel) of each call
strace -p $pid -T -o /sdcard/$file

# Count total calls and CPU time
strace -p $pid -c -o /sdcard/$file

# Log (wall clock) start time of each call
strace -p $pid -ttt -o /sdcard/$file

# Profile (wall clock) start time and CPU time of each call
strace -p $pid -T -ttt -o /sdcard/$file

# Account total CPU time for ioctl 
pid=4727
fd=$(adb shell ls -l /proc/$pid/fd | grep kgsl | cut -d':' -f2 | cut -d' ' -f2)
c=0
for s in $(cat ocr.strace.out | grep "ioctl($fd," | grep ">" | grep "=" | cut -d')' -f2- | cut -d'<' -f2- | cut -d'<' -f2- | cut -d'<' -f2- | cut -d'>' -f1); 
do 
   c=$(echo "$c + $s" | bc)
done
echo $c
