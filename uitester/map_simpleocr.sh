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
           echo "$i,$f"
           cat trace.$i | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > trace.$i.$ptid
       fi
   done
done
rm tmpid
