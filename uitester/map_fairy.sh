# Get UI input
for f in $(cat fairy.logcat.out | grep TouchEvent | cut -d':' -f4 | cut -d' ' -f22 | cut -c1-10); do cat sorted.nexus4.fairy.decoded | grep UI_INPUT | grep $f; done > sorted.nexus4.fairy.ui

# Extract relevant threads
for l in $(cat thread_name.out | grep "Thread\-"); do f=$(echo $l | cut -d':' -f7 | cut -d',' -f1); t=$(echo $l | cut -d':' -f4 | cut -d',' -f1); if [ $(cat fork.tid | grep "pid\":$f," | grep $t | wc -l) -gt 0 ]; then cat thread_name.out | grep "Thread\-" | grep "pid\":$f," | grep $t; cat fork.tid | grep "pid\":$f," | grep $t; fi; done > thread.tid
i=1; for l in $(cat sorted.nexus4.fairy.ui | cut -d':' -f4 | cut -d',' -f1); do if [ $(cat thread.tid | grep FORK | grep $l | wc -l) -eq 1 ]; then ptid=$(cat thread.tid | grep FORK | grep $l | cut -d':' -f10 | cut -d',' -f1); cat trace.$i | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > trace.$i.$ptid; fi; i=$(($i+1)); done 
