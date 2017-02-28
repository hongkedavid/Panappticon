# Profile wall clock time of each call
strace -p $pid -T -o /sdcard/$file

# Count total calls and CPU time
strace -p $pid -c -o /sdcard/$file

# Log start time of each call
strace -p $pid -ttt -o /sdcard/$file

# Profile wall clock start time and run time of each call
strace -p $pid -T -ttt -o /sdcard/$file
