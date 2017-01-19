mkdir generic_resprof/
mv trace.* fork.tid profile_resource.sh dtree.py extract*py generic_resprof/
cd generic_resprof

tid=6620
for j in $(ls trace.* | cut -d'.' -f2 | sort -n);
do 
    rm $j.*_stat
    n1=$(cat trace.$j | grep -n UI_INPUT | cut -d':' -f1)
    n2=$(cat trace.$j | wc -l)
    last_sec=$(cat trace.$j | tail -n1 | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
    rm thread.$j
    for i in $(cat trace.$j | tail -n $(($n2-$n1+1)) | grep CONTEXT_SWITCH | cut -d'{' -f4 | cut -d':' -f3 | cut -d',' -f1 | sort | uniq);
    do 
        if [ $(cat fork.tid | grep ":$i,\"tgid\":$tid}}" | wc -l) -gt 0 ]; then 
            sec=$(cat fork.tid | grep ":$i,\"tgid\":$tid}}" | cut -d'{' -f3 | cut -d':' -f2 | cut -d',' -f1)
            if [ $sec -lt $last_sec ]; then 
                echo $i >> thread.$j
            fi
        fi
    done
    for ptid in $(cat thread.$j);
    do
        cat trace.$j | tail -n $(($n2-$n1+1)) | grep "pid\":$ptid,\|new\":$ptid,\|pid\":$ptid}}" > tmp.trace
        ./profile_resource.sh tmp.trace
        cat tmp.trace.cpu | python extractCPUResource.py $ptid >> $j.cpu_stat
        cat tmp.trace.sock | python extractIOResource.py $ptid >> $j.sock_stat
        cat tmp.trace.disk | python extractIOResource.py $ptid >> $j.disk_stat
    done
    rm thread.$j
done
rm tmp.trace*
rm resource.csv
for t in $(ls trace.* | cut -d'.' -f2 | sort -n);
do
    for ((j=2;j<=4;j=j+1));
    do
        c=0;
        for f in $(cat $t.cpu_stat | cut -d' ' -f$j);
        do
            c=$(($c+$f));
        done;
        echo -n "$c " >> resource.csv;
    done;
    c=0;
    for f in $(cat $t.sock_stat | cut -d' ' -f2);
    do
        c=$(($c+$f));
    done;
    echo -n "$c " >> resource.csv;
    c=0
    for f in $(cat $t.disk_stat | cut -d' ' -f2);
    do
        c=$(($c+$f));
    done;
    echo -n "$c" >> resource.csv;
    echo "" >> resource.csv;
done 
