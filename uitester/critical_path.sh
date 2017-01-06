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
if [ ! $c1 ]; then 
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
if [ ! $c1 ]; then 
   a=$(cat $f | grep "3938 xit" | grep "MessageQueue.next" | head -n1 | cut -c1-30)
   c1=$(grep -n "$a" $f | head -n1 | cut -d':' -f1)
fi
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
s="3938"
for t in $(cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | sort | uniq); 
do 
    if [ $t -gt 3938 ]; then 
        line=$(cat sorted.nexus4.cnet.decoded | grep 147398685 | grep "pid\":$t}\|pid\":$t," | head -n1)
        if [ $(echo $line | grep FUTEX_NOTIFY | wc -l) -gt 0 ]; then 
            p1=$(echo $line | cut -d':' -f7 | cut -d',' -f1)
            p2=$(echo $line | cut -d'{' -f4 | cut -d':' -f3 | cut -d'}' -f1)
            if [ $t -eq $p2 ] && [ $(cat sorted.nexus4.cnet.decoded | grep 147398685 | grep "pid\":$t," | grep "ENQUEUE\|NOTIFY" | tail -n5 | grep ":$p1}}" | wc -l) -gt 0 ]; then
               echo $t, $p1, $p2
               s="$s\|$t"
            fi
        fi
    fi
done
stk=""; for j in $(cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | uniq | grep "$s"); do if [ $(echo $stk | grep "$j," | wc -l) -eq 0 ]; then echo $j; stk=$(echo "$stk""$j,"); fi; done

# Vine
c1=$(grep -n "ActivityThread.handleLaunchActivity" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "FetchRunnable" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | uniq
s="3619"
for t in $(cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -d' ' -f1 | sort | uniq); 
do 
    if [ $t -gt 3619 ]; then 
        line=$(cat sorted.nexus4.vine.decoded | grep "147275323\|147275324" | grep "pid\":$t}\|pid\":$t," | head -n1)
        if [ $(echo $line | grep FUTEX_NOTIFY | wc -l) -gt 0 ]; then 
            p1=$(echo $line | cut -d':' -f7 | cut -d',' -f1)
            p2=$(echo $line | cut -d'{' -f4 | cut -d':' -f3 | cut -d'}' -f1)
            if [ $t -eq $p2 ] && [ $(cat sorted.nexus4.vine.decoded | grep "147275323\|147275324" | grep "pid\":$t," | grep "ENQUEUE" | tail -n5 | grep ":$p1}}" | wc -l) -gt 0 ]; then
               echo $t, $p1, $p2
               s="$s\|$t"
            fi
        fi
    fi
done
stk=""; for j in $(cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq | grep "$s"); do if [ $(echo $stk | grep "$j," | wc -l) -eq 0 ]; then echo $j; stk=$(echo "$stk""$j,"); fi; done

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
c1=$(grep -n "ActivityThread.handleLaunchActivity" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq

# Offerup
c1=$(grep -n "ActivityThread.handleLaunchActivity" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq

# Google Translate
c1=$(grep -n "ActivityThread.handleResumeActivity" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq

# WhereAmI
c1=$(grep -n "PerformClick.run" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "performTraversals" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq

# OCR
c1=$(grep -n "PerformClick.run" $f | head -n1 | cut -d':' -f1)
c2=$(grep -n "MainActivity\$16.doInBackground" $f | tail -n1 | cut -d':' -f1)
cat $f | head -n$c2 | tail -n$(($c2-$c1+1)) | cut -c1-2 | uniq

# Get upcalls
cat *.out | grep " \.\.\." | grep -v " \.\.\.\." 

