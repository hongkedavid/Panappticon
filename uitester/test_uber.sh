# Test and analyze the app launch and destination search interaction in Uber rider app on Nexus 6
adb shell 
logcat -v time -f /sdcard/uber.logcat &
su
tcpdump -i wlan0 -w /sdcard/uber.tcpdump &

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


# Test and analysis step for the ride request interaction in Uber rider app on Nexus 6
# Start logcat
adb shell
logcat -v time -f /sdcard/uber_rider.logcat &

# Using MTCPDUMP to capture traffic
su
mtcpdump -i wlan0 & 
 
# Collect tcpdump, logcat, Traceview and Panappticon traces
# On Mac
pcap_folder="imap-2017-01-22-20-11-05"
mkdir $pcap_folder; cd $pcap_folder
adb pull /sdcard/IMAP/$pcap_folder/ .
adb pull /sdcard/uber_rider.logcat .
scp -r $pcap_folder david@rome.eecs.umich.edu:/nfs/rome2/david/paco/uber_pp_n6/
# On rome server
pcap_folder="imap-2017-01-22-20-11-05"
mkdir /nfs/rome2/david/uber/$pcap_folder; mkdir /nfs/rome2/david/uber/$pcap_folder/kernel; mkdir /nfs/rome2/david/uber/$pcap_folder/user
scp kehong@141.212.110.134:~/panappticon-src/panappticon-tools/EventLoggingServer/bin/72d9edcfe5b9ac90d69f766364dbdd7b/kernel/148513* /nfs/rome2/david/uber/$pcap_folder/kernel/
scp kehong@141.212.110.134:~/panappticon-src/panappticon-tools/EventLoggingServer/bin/72d9edcfe5b9ac90d69f766364dbdd7b/user/148513* /nfs/rome2/david/uber/$pcap_folder/user/
echo "/nfs/rome2/david/paco/uber_pp_n6/$pcap_folder/traffic.cap" > /nfs/rome2/david/paco/PACO/pcapsort
# On Mac
ls -ltU /var/folders/47/1v76mm497qvd1dkkm32bdvpm0000gn/T/ddms* | grep "Jan 22" | cut -d'/' -f7 > traceview.info
for f in $(cat traceview.info); do scp /var/folders/47/1v76mm497qvd1dkkm32bdvpm0000gn/T/$f david@rome.eecs.umich.edu:/nfs/rome2/david/uber/$pcap_folder/; done
scp traceview.info david@rome.eecs.umich.edu:/nfs/rome2/david/uber/$pcap_folder/

# Parsing tcpdump trace uisng PACO 
cd /nfs/rome2/david/paco
./paco 1

# Parsing logcat trace to get input timestamp
cat uber_rider.logcat | grep TouchEvent | grep com.ubercab > tmp
grep -n "TouchEvent View com.ubercab.ui.core.UButton Parent com.ubercab.ui.core.ULinearLayout\|TouchEvent View com.ubercab.ui.core.UButton Parent com.ubercab.presidio.app.optional.root.main.ride.request.plus_one.steps.surge.PlusOneSobrietyStepView" tmp > tmp.tmp 
# DestinationSearchPromptView -> URecyclerView -> DefaultConfirmationButtonView -> com.ubercab.ui.core.UButton (-> PlusOneSobrietyStepView) -> com.ubercab.ui.core.UButton
vi tmp.tmp
cut -d':' -f5 tmp.tmp | cut -d' ' -f22 > uber_rider.ui 
rm tmp tmp.tmp
scp uber_rider.ui david@rome.eecs.umich.edu:/nfs/rome2/david/uber/$pcap_folder/

# Parsing Traceview and Panappticon trace
cd /nfs/rome2/david/uber/$pcap_folder
./parse_event.sh
tid=$(cat nexus6.uber.decoded | grep com.ubercab | head -n1 | cut -d'{' -f4 | cut -d':' -f2 | cut -d',' -f1)
i=$(cat ddms* | wc -l); for f in $(cat traceview.info); do ./dmtracedump -o $f > $tid.$i.tracedump; i=$(($i-1)); done

# Map SSL_do_handshake in Traceview to fow setup in tcpdump
# tcpflow->start_time, tcpflow->last_tcp_ts
cat PACO/flow_summary_1 | grep com.ubercab | cut -d' ' -f12,25

k=6; init=1485035503163000
start=$(cat trace_view_$k.dump | grep performClick | head -n1 | cut -d' ' -f2- | cut -c15-23 | sed 's/ //g')
for i in $(cat trace_view_$k.dump | grep SSL_do_handshake | cut -d' ' -f1 | sort | uniq); 
do 
    cat trace_view_$k.dump | grep "$i " | head -n1
    for t in $(cat $i.$k.out | grep SSL_do_handshake | grep ent | cut -c20-29 | sed 's/ //g');
    do
        curr=$(($t-$start+$init))
        echo "$i, $(($curr/1000000)).$(($curr%1000000))"
    done
done

# Map SSL_read in Traceview to payload receive in tcpdump
# tcpflow->first_ul_pl_time, tcpflow->first_dl_pl_time, tcpflow->last_ul_pl_time, tcpflow->last_dl_pl_time, tcpflow->ul_time, tcpflow->dl_time
cat PACO/flow_summary_1 | grep com.ubercab | cut -d' ' -f15-18,23,24

k=6; init=1485035503163000
start=$(cat trace_view_$k.dump | grep performClick | head -n1 | cut -d' ' -f2- | cut -c15-23 | sed 's/ //g')
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

for ptid in $(cat flow_read.info | grep OkHttpcn | cut -d',' -f2 | sort | uniq); 
do  
    cat nexus6.uber.decoded | grep "pid\":$ptid,\|new\":$ptid,\|:$ptid}}" > trace.$ptid
    n=$(cat trace.$ptid | wc -l)
    m=$(grep -n "pid\":$ptid,\"tgid\":$tid" trace.$ptid | cut -d':' -f1)
    cat trace.$ptid | tail -n$(($n-$m+1)) > trace.$ptid.tmp
    mv trace.$ptid.tmp trace.$ptid
done
