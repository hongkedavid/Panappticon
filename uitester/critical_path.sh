# Sudoku: id.out   
c1=$(grep -n "PerformClick.run" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq

# Downloadmgr
a=$(cat $f | grep "3793 xit" | grep "MessageQueue.next" | head -n1 | cut -c1-30)
c1=$(grep -n "$a" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | uniq

# SSE-IO
c1=$(grep -n "PerformClick.run" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq

# SSE-CPU
c1=$(grep -n "PerformClick.run" $f | head -n1 | cut -d':' -f1)
if [ !$c1 ]; then 
   a=$(cat $f | grep "4003 xit" | grep "MessageQueue.next" | head -n1 | cut -c1-30) 
   c1=$(grep -n "$a" $f | head -n1 | cut -d':' -f1)
fi
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | uniq

# HM
c1=$(grep -n "PerformClick.run" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | uniq

# CNET
c1=$(grep -n "PerformClick.run" $f | head -n1 | cut -d':' -f1)
if [ !$c1 ]; then 
   a=$(cat $f | grep "3938 xit" | grep "MessageQueue.next" | head -n1 | cut -c1-30)
   c1=$(grep -n "$a" $f | head -n1 | cut -d':' -f1)
fi
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | uniq

# Vine
c1=$(grep -n "ActivityThread.handleLaunchActivity" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "FetchRunnable" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | uniq

# Sina
c1=$(grep -n "ActivityThread.handleLaunchActivity" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | uniq

# VLC
c1=$(grep -n "ActivityThread\$H.handleMessage" $f | head -n2 | tail -n1 | cut -d':' -f1)
c1=$(($c1+4))
c2=$(grep -n "MediaCodec.start " $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1))  | cut -c1-2 | uniq

# Meitu
c1=$(grep -n "ActivityThread.handleLaunchActivity" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "b\$1.run" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq

# Flipp

# 

# WhereAmI

# OCR
c1=$(grep -n "PerformClick.run" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "MainActivity\$16.doInBackground" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq


cat trace_view_1.dump | grep "\.\.\." | cut -c1-2 | uniq
