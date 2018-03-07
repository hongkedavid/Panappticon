for f in $(cat simpleocr.logcat.out | grep TouchEvent | cut -d':' -f4 | cut -d' ' -f22 | cut -c1-10); do cat sorted.nexus4.simpleocr.decoded | grep UI_INPUT | grep $f; done > sorted.nexus4.simpleocr.ui 
for l in $(cat thread_name.out | grep "AsyncTask"); do f=$(echo $l | cut -d':' -f7 | cut -d',' -f1); t=$(echo $l | cut -d':' -f4 | cut -d',' -f1); if [ $(cat fork.tid | grep "pid\":$f," | grep $t | wc -l) -gt 0 ]; then cat thread_name.out | grep "AsyncTask" | grep "pid\":$f," | grep $t; cat fork.tid | grep "pid\":$f," | grep $t; fi; done > asynctask.tid

# Extrace relevant thread
cat asynctask.tid | grep THREAD | cut -d':' -f7 | cut -d',' -f1 > tmpid
for i in $(cut -d',' -f1 simpleocr.latency); 
do   
   tt=$(cat trace.$i | head -n1 | cut -d':' -f4 | cut -d',' -f1); 
   for ptid in $(cat tmpid);
   do 
       if [ $(cat trace.$i | grep ":$ptid}}" | grep "pid\":1945" | grep "$tt\|$(($tt+1))" | wc -l) -gt 0 ]; then 
           echo "$i,$ptid"
           cat trace.$i | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > trace.$i.$ptid
       fi
   done
done
rm tmpid

# Profile resource usage
for ll in $(cat simpleocr.latency);
do
    i=$(echo $ll | cut -d',' -f1)
    t=$(echo $ll | cut -d',' -f2)
    if [ $(ls trace.$i.* | wc -l) -eq 0 ]; then continue; fi
    ptid=$(ls trace.$i.* | head -n1 | cut -d'.' -f3)
    ./profile_resource.sh trace.$i.$ptid
    rm $i.cpu_stat $i.sock_stat $i.disk_stat
    cat trace.$i.$ptid.cpu | python extractCPUResource.py $ptid >> $i.cpu_stat
    cat trace.$i.$ptid.sock | python extractIOResource.py $ptid >> $i.sock_stat
    cat trace.$i.$ptid.disk | python extractIOResource.py $ptid >> $i.disk_stat
done
