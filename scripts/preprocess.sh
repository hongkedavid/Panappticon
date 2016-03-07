# profile thread metrics
sh filter_proc_tid.sh sorted.all.nexus6.activem.decoded 2278 > codec-vp9-nexus6-active.tid
sh profile_cpu_lock.sh

# compute thread-qoe correlation
sh compute_thread_corr.sh 4000 codec-vp9-nexus6.qoe

# generate SVM training input
./gen_svm_input.sh 4000 codec-vp9-nexus6.qoe svm-vp9-nexus6-correlate.train

# generate DT training input
./gen_svm_input.sh 4000 codec-vp9-nexus6.qoe svm-vp9-nexus6-train.csv
python dtree.py svm-vp9-nexus6-train.csv

# get all thread IDs
sh get_thread_id.sh sorted.all.nexus6.activem.decoded > all.tid
./unify_feature.sh 0 $start $end

sh plot_thread.sh 4000 codec-vp9-nexus6.qoe

sh get_futex_event sorted.all.nexus6.activem.decoded $tid
cat futext_event.$tid1 | python ComputeFutexTime.py $tid2 > $tid1_$tid2.out

sh profile_binder.sh codec-vp9-nexus6-active.tid
sh compute_binder_corr.sh 4000 codec-vp9-nexus6.qoe
