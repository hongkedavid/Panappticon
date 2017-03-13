# CPU contention
for i in $(ls scryptN.*.trace | cut -d'.' -f2 | sort -n); 
do 
    if [ $i -eq 18 ]; then continue; fi
    f="scryptN.$i.trace"
    echo $i
    cat $f | head -n1 | cut -d':' -f4 | cut -d',' -f1
    t=$(cat $f | head -n1 | cut -d':' -f4 | cut -d',' -f1 | cut -c1-9)
    cat sorted.nexus4.encryptsse.decoded | grep UI_INPUT | grep $t
done

c=1
for i in $(ls scryptN.*.trace | cut -d'.' -f2 | sort -n); 
do 
    if [ $i -eq 18 ]; then continue; fi
    f="scryptN.$i.trace"
    str=$(cat nexus4.encryptsse.ui | head -n$c | tail -n1)
    n1=$(grep -n "$str" sorted.nexus4.encryptsse.decoded | cut -d':' -f1)
    str=$(cat $f | tail -n1) 
    n2=$(grep -n "$str" sorted.nexus4.encryptsse.decoded | cut -d':' -f1)
    cat sorted.nexus4.encryptsse.decoded | head -n$n2 | tail -n$(($n2-$n1+1)) > trace.$i
    c=$(($c+1))
done


# Slow IO
for t in $(cat see.logcat.out | cut -d'T' -f5 | cut -d' ' -f2 | cut -c1-10);
do 
    cat nexus4.user.encryptsse.decoded | grep UI_INPUT | grep $t
done

for line in $(cat nexus4.encryptsse.ui);
do
    i=$(echo $line | cut -d':' -f1)
    str=$(echo $line | cut -d':' -f2-)
    n1=$(grep -n "$str" sorted.nexus4.encryptsse.decoded | cut -d':' -f1)
    f=$(ls *.$i.trace)
    str=$(cat $f | grep EXIT | tail -n1) 
    n2=$(grep -n "$str" sorted.nexus4.encryptsse.decoded | cut -d':' -f1)
    echo $n1, $n2
    cat sorted.nexus4.encryptsse.decoded | head -n$n2 | tail -n$(($n2-$n1+1)) > trace.$i
done


# Sudoku
for t in $(cat sudoku.logcat.out | grep TouchEvent | cut -d'T' -f4 | cut -d' ' -f2 | cut -c1-10);
do 
    cat sorted.nexus4.sudoku.decoded | grep UI_INPUT | grep $t
done > nexus4.sudoku.ui

for i in $(cat id.out);
do
    str=$(cat nexus4.sudoku.ui | head -n$i | tail -n1)
    n1=$(grep -n "$str" sorted.nexus4.sudoku.decoded  | cut -d':' -f1)
    sec=$(echo $str | cut -d':' -f4 | cut -d',' -f1)
    usec=$(echo $str | cut -d':' -f5 | cut -d'}' -f1)
    tt=$(cat sudoku.latency | head -n$i | tail -n1 | cut -f3)
    tt=$(($(($sec*1000000))+$(($tt*1000))+$usec))
    sec=$(($tt/1000000))
    usec=$(($tt%1000000))
    usectmp=$(echo $usec | cut -c1)
    for str in $(cat sorted.nexus4.sudoku.decoded | grep "$sec,\"usec\":$usectmp" | cut -d':' -f5 | cut -d'}' -f1);
    do
        if [ $usec -lt $str ]; then
            n2=$(cat sorted.nexus4.sudoku.decoded | grep -n "$sec,\"usec\":$str" | tail -n1 | cut -d':' -f1)
            break
        fi
    done
    echo $n1, $n2
    cat sorted.nexus4.sudoku.decoded | head -n$n2 | tail -n$(($n2-$n1+1)) > trace.$i
done


# hm
for ((i=1;i<=24;i=i+1)); do t1=$(cat trace_view_$i.dump | grep "PerformClick.run" | head -n1 | cut -c20-28 | sed 's/ //g'); t2=$(cat trace_view_$i.dump | grep "ViewRootImpl.performTraversals" | tail -n1 | cut -c20-28 | sed 's/ //g'); echo "$i $(($t2-$t1))"; done > hm.latency
for line in $(cat nexus4.hm.ui);
do
    i=$(echo $line | cut -d':' -f1)
    str=$(echo $line | cut -d':' -f2-)
    n1=$(grep -n "$str" sorted.nexus4.hm.decoded  | cut -d':' -f1)
    sec=$(echo $str | cut -d':' -f4 | cut -d',' -f1)
    usec=$(echo $str | cut -d':' -f5 | cut -d'}' -f1)
    tt=$(cat hm.latency | head -n$i | tail -n1 | cut -d' ' -f2)
    tt=$(($(($sec*1000000))+$tt+$usec))
    sec=$(($tt/1000000))
    usec=$(($tt%1000000))
    usectmp=$(echo $usec | cut -c1)
    for str in $(cat sorted.nexus4.hm.decoded | grep "$sec,\"usec\":$usectmp" | cut -d':' -f5 | cut -d'}' -f1);
    do
        if [ $usec -lt $str ]; then
            n2=$(cat sorted.nexus4.hm.decoded | grep -n "$sec,\"usec\":$str" | tail -n1 | cut -d':' -f1)
            break
        fi
    done
    echo $n1, $n2
    cat sorted.nexus4.hm.decoded | head -n$n2 | tail -n$(($n2-$n1+1)) > trace.$i
done


# DownloadMgr
for ((i=1;i<=20;i=i+1)); do t1=$(cat trace_view_$i.dump | grep "onClick\|doConsumeBatchedInput" | head -n1 | cut -c20-28 | sed 's/ //g'); t2=$(cat trace_view_$i.dump | grep "ViewRootImpl.performTraversals" | tail -n1 | cut -c20-28 | sed 's/ //g'); echo "$i $(($t2-$t1))"; done > downloadmgr.latency

for i in $(ls recvfrombytes.*.trace | cut -d'.' -f2 | sort -n); 
do 
    f="recvfrombytes.$i.trace"
    echo $i
    cat $f | head -n1 | cut -d':' -f4 | cut -d',' -f1
    t=$(cat $f | head -n1 | cut -d':' -f4 | cut -d',' -f1 | cut -c1-9)
    cat sorted.nexus4.downloadmgr.decoded | grep UI_INPUT | grep $t
done

for i in $(ls recvfrombytes.*.trace | cut -d'.' -f2 | sort -n); 
do
    str=$(cat nexus4.downloadmgr.ui | head -n$i | tail -n1)
    n1=$(grep -n "$str" sorted.nexus4.downloadmgr.decoded  | cut -d':' -f1)
    sec=$(echo $str | cut -d':' -f4 | cut -d',' -f1)
    usec=$(echo $str | cut -d':' -f5 | cut -d'}' -f1)
    tt=$(cat downloadmgr.latency | head -n$i | tail -n1 | cut -d' ' -f2)
    tt=$(($(($sec*1000000))+$tt+$usec))
    sec=$(($tt/1000000))
    usec=$(($tt%1000000))
    usectmp=$(echo $usec | cut -c1)
    for str in $(cat sorted.nexus4.downloadmgr.decoded | grep "$sec,\"usec\":$usectmp" | cut -d':' -f5 | cut -d'}' -f1);
    do
        if [ $usec -lt $str ]; then
            n2=$(cat sorted.nexus4.downloadmgr.decoded | grep -n "$sec,\"usec\":$str" | tail -n1 | cut -d':' -f1)
            break
        fi
    done
    echo $n1, $n2
    cat sorted.nexus4.downloadmgr.decoded | head -n$n2 | tail -n$(($n2-$n1+1)) > trace.$i
done


# CNET
for ((i=1;i<=22;i=i+1)); do t1=$(cat trace_view_$i.dump | grep "PerformClick.run\|Activity.performPause" | head -n1 | cut -c20-28 | sed 's/ //g'); t2=$(cat trace_view_$i.dump | grep "ViewRootImpl.performTraversals" | tail -n1 | cut -c20-28 | sed 's/ //g'); echo "$i $(($t2-$t1))"; done > cnet.latency

i=1
for str in $(cat nexus4.cnet.ui);
do
    n1=$(grep -n "$str" sorted.nexus4.cnet.decoded  | cut -d':' -f1)
    sec=$(echo $str | cut -d':' -f4 | cut -d',' -f1)
    usec=$(echo $str | cut -d':' -f5 | cut -d'}' -f1)
    i=$(cat cnet.latency | head -n$i | tail -n1 | cut -d' ' -f1)
    tt=$(cat cnet.latency | head -n$i | tail -n1 | cut -d' ' -f2)
    tt=$(($(($sec*1000000))+$tt+$usec))
    sec=$(($tt/1000000))
    usec=$(($tt%1000000))
    usectmp=$(echo $usec | cut -c1)
    n2=0
    for str in $(cat sorted.nexus4.cnet.decoded | grep "$sec,\"usec\":$usectmp" | cut -d':' -f5 | cut -d'}' -f1);
    do
        if [ $usec -lt $str ]; then
            n2=$(cat sorted.nexus4.cnet.decoded | grep -n "$sec,\"usec\":$str" | tail -n1 | cut -d':' -f1)
            break
        fi
    done
    if [ $n2 -eq 0 ]; then
       str=$(cat sorted.nexus4.cnet.decoded | grep "$sec,\"usec\":$usectmp" | cut -d':' -f5 | cut -d'}' -f1 | tail -n1)
       n2=$(cat sorted.nexus4.cnet.decoded | grep -n "$sec,\"usec\":$str" | tail -n1 | cut -d':' -f1)
    fi
    echo $n1, $n2
    cat sorted.nexus4.cnet.decoded | head -n$n2 | tail -n$(($n2-$n1+1)) > trace.$i
    i=$(($i+1))
done
