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

# Extract relevant intervals

# Compute resource features  
