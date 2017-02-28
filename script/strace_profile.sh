# Profile wall clock time of each call
strace -p $pid -T -o /sdcard/$file

# Count total calls and CPU time
strace -p $pid -c -o /sdcard/$file

# Log start time of each call
strace -p $pid -ttt -o /sdcard/$file
