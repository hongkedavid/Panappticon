tid=3203
func="SSL_read"
for f in $(ls $tid.*traceview); 
do 
     echo $f; 
     for tid in $(cat $f | grep "$func" | cut -d' ' -f1 | sort -n | uniq); 
     do 
         cat $f | grep "$tid " | head -n1; 
     done; 
done 

# Extract relevant threads
file="nexus4.translate.decoded"
cat $file | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
cat $file | grep FORK | grep "tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid
for f in $(ls $tid.*traceview); 
do 
    tname=$(grep S3LibThread $f | head -n2 | tail -n1 | cut -d' ' -f2); 
    l=$(grep -n "$tname\"" thread_name.out | head -n1); c1=$(echo $l | cut -d':' -f1); 
    t=$(echo $l | cut -d':' -f5 | cut -d',' -f1); 
    for ((i=10;i<=15;i=i+1)); 
    do 
        if [ $(grep -n "$(($t+$i))" thread_name.out | wc -l) -gt 0 ]; then 
            c2=$(grep -n "$(($t+$i))" thread_name.out | head -n1 | cut -d':' -f1); 
            break; 
        fi;
    done
    echo $f; 
    cat thread_name.out | head -n$c2 | tail -n$(($c2-$c1)) | grep "pool\-" | grep "thread\-\"\|thread\""; 
done

# Extract relevant intervals

# Compute resource features  
