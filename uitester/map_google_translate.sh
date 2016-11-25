tid=3203

# Extract relevant threads
cat nexus4.translate.decoded | grep THREAD > thread_name.out
./sort_json.sh thread_name.out
mv sorted.thread_name.out thread_name.out
cat nexus4.translate.decoded | grep FORK | grep "tgid\":$tid}}" > fork.tid
./sort_json.sh fork.tid
mv sorted.fork.tid fork.tid

# Extract relevant intervals

# Compute resource features  
