# Profile wall clock time of each call
strace -p $pid -T -o /sdcard/$file

# Count total calls and CPU time
strace -p $pid -c -o /sdcard/$file

# Log start time of each call
strace -p $pid -ttt -o /sdcard/$file

# Profile wall clock start time and run time of each call
strace -p $pid -T -ttt -o /sdcard/$file


fd=$(adb shell ls -l /proc/4727/fd | grep kgsl | cut -d':' -f2 | cut -d' ' -f2)
c=0
for s in $(cat ocr.strace.out | grep "ioctl($fd," | cut -d'=' -f2 | cut -d' ' -f3 | cut -d'<' -f2 | cut -d'>' -f1); 
do 
   c=$(echo "$c + $s" | bc)
done
echo $c
