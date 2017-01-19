tid=6620
last_sec=$(cat trace.$j | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
rm thread.$j
for i in $(cat trace.$j | grep CONTEXT_SWITCH | cut -d'{' -f4 | cut -d':' -f3 | cut -d',' -f1 | sort | uniq);
do 
    if [ $(cat fork.tid | grep ":$i,\"tgid\":$tid}}" | wc -l) -gt 0 ]; then 
       sec=$(cat fork.tid | grep ":$i,\"tgid\":$tid}}" | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
       if [ $sec -lt $last_sec ]; then 
           echo $i >> thread.$j
       fi
    fi
done
for $ptid in $(cat thread.$j);
do
    cat trace.$j | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > tmp.trace
    ./profile_resource.sh tmp.trace
    cat tmp.trace.cpu | python extractCPUResource.py $ptid >> $j.cpu_stat
    cat tmp.trace.sock | python extractIOResource.py $ptid >> $j.sock_stat
    cat tmp.trace.disk | python extractIOResource.py $ptid >> $j.disk_stat
done
rm thread.$j
