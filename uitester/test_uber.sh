adb shell 
su
tcpdump -i wlan0 -w /sdcard/uber.tcpdump &
logcat -v time -f /sdcard/uber.logcat &

cat uber.logcat | grep "TouchEvent\|Monkey\|triggerGloba" | grep "TouchEvent\|Monkey\|uber" > uber.logcat.out
for i in $(grep -n "tap 705 1160" uber.logcat.out | cut -d':' -f1); do cat uber.logcat.out | head -n$(($i+1)) | tail -n1; done | cut -d' ' -f2 > tmp.1
for i in $(grep -n "tap 560 1900" uber.logcat.out | cut -d':' -f1); do cat uber.logcat.out | head -n$(($i-1)) | tail -n1; done | cut -d' ' -f2 > tmp.2
paste -d' ' tmp.1 tmp.2 > tmp.3
sed 's/://g' tmp.3 > tmp.4; sed 's/\.//g' tmp.4 > tmp.3
awk '{print ($2-$1)}' tmp.3 > tmp.4 
paste tmp.1 tmp.2 tmp.4 > uber.launch_latency

for i in $(grep -n "tap 560 1900" uber.logcat.out | cut -d':' -f1); do cat uber.logcat.out | head -n$(($i+1)) | tail -n1; done | cut -d' ' -f2 > tmp.1
for i in $(grep -n "press KEYCODE_APP_SWITCH" uber.logcat.out | cut -d':' -f1); do cat uber.logcat.out | head -n$(($i-1)) | tail -n1; done | cut -d' ' -f2 > tmp.2
paste -d' ' tmp.1 tmp.2 > tmp.3
sed 's/://g' tmp.3 > tmp.4; sed 's/\.//g' tmp.4 > tmp.3
awk '{print ($2-$1)}' tmp.3 > tmp.4 
paste tmp.1 tmp.2 tmp.4 > uber.pick_latency
rm tmp.1 tmp.2 tmp.3 tmp.4

paste uber.launch_latency uber.pick_latency | cut -f1,2,4,5 | sed 's/\t/,/g' > uber.latency
tcpdump -r uber.tcpdump ip and not host yuanyuanzhou-hp.eecs.umich.edu -n > uber.tcpdump.out 
c=1; for l in $(cat uber.latency); do t1=$(echo $l | cut -d',' -f1 | cut -c1-7); t2=$(echo $l | cut -d',' -f2 | cut -c1-7); n1=$(grep -n "$t1" uber.tcpdump.out | head -n1 | cut -d':' -f1); n2=$(grep -n "$t1" uber.tcpdump.out | tail -n1 | cut -d':' -f1); n3=$(grep -n "$t2" uber.tcpdump.out | head -n1 | cut -d':' -f1); n4=$(grep -n "$t2" uber.tcpdump.out | tail -n1 | cut -d':' -f1); if [ ! $n1 ]; then a=$n3; b=$n4; elif [ ! $n3 ]; then a=$n1; b=$n2; else a=$n1; b=$n4; fi; cat uber.tcpdump.out | head -n$b | tail -n$(($b-$a+1)) > uber.launch_trace.$c; c=$(($c+1)); done
c=1; for l in $(cat uber.latency); do t1=$(echo $l | cut -d',' -f3 | cut -c1-7); t2=$(echo $l | cut -d',' -f4 | cut -c1-7); n1=$(grep -n "$t1" uber.tcpdump.out | head -n1 | cut -d':' -f1); n2=$(grep -n "$t1" uber.tcpdump.out | tail -n1 | cut -d':' -f1); n3=$(grep -n "$t2" uber.tcpdump.out | head -n1 | cut -d':' -f1); n4=$(grep -n "$t2" uber.tcpdump.out | tail -n1 | cut -d':' -f1); if [ ! $n1 ]; then a=$n3; b=$n4; elif [ ! $n3 ]; then a=$n1; b=$n2; else a=$n1; b=$n4; fi; cat uber.tcpdump.out | head -n$b | tail -n$(($b-$a+1)) > uber.pick_trace.$c; c=$(($c+1)); done


# Using MTCPDUMP to capture traffic
 mtcpdump -i wlan0 & 
 adb pull /sdcard/IMAP/imap-2017-01-21-16-51-28/ .
 
# Parsing pcap trace uisng PACO
./paco 1

# tcpflow->start_time, tcpflow->last_tcp_ts
cat PACO/flow_summary_1 | grep uber | cut -d' ' -f12,25

k=6; init=1485035503163000
start=$(cat trace_view_$k.dump | grep performClick | head -n1 | cut -c20-29 | sed 's/ //g')
for i in $(cat trace_view_$k.dump | grep SSL_do_handshake | cut -d' ' -f1 | sort | uniq); 
do 
    cat trace_view_$k.dump | grep "$i " | head -n1
    for t in $(cat $i.$k.out | grep SSL_do_handshake | grep ent | cut -c20-29 | sed 's/ //g');
    do
        curr=$(($t-$start+$init))
        echo "$i, $(($curr/1000000)).$(($curr%1000000))"
    done
done

# tcpflow->first_ul_pl_time, tcpflow->first_dl_pl_time, tcpflow->last_ul_pl_time, tcpflow->last_dl_pl_time, tcpflow->ul_time, tcpflow->dl_time
cat PACO/flow_summary_1 | grep uber | cut -d' ' -f15-18,23,24

k=6; init=1485035503163000
start=$(cat trace_view_$k.dump | grep performClick | head -n1 | cut -c20-29 | sed 's/ //g')
for i in $(cat trace_view_$k.dump | grep SSL_read | cut -d' ' -f1 | sort | uniq); 
do 
    cat trace_view_$k.dump | grep "$i " | head -n1
    c=1
    for t in $(cat $i.$k.out | grep SSL_read | cut -c20-29 | sed 's/ //g');
    do
        curr=$(($t-$start+$init))
        if [ $(($c%2)) -gt 0 ]; then
            echo -n "$i, $(($curr/1000000)).$(($curr%1000000)) "
        else
            echo "$(($curr/1000000)).$(($curr%1000000))"
        fi
        c=$(($c+1))
    done
    if [ $(($c%2)) -eq 0 ]; then echo ""; fi
done
