# profile thread metrics
sh filter_proc_tid.sh sorted.all.vp9.nexus6 2278 > codec-vp9-nexus6-active.tid
sh profile_cpu_lock.sh

# compute thread-qoe correlation
sh compute_thread_corr.sh 4000 codec-vp9-nexus6.qoe

# profile all thread metrics
sh get_thread_id.sh sorted.all.vp9.nexus6 > all.tid
sh profile_cpu_lock.sh
./unify_feature.sh 0 $start $end

# generate SVM training input
./gen_svm_input.sh 4000 codec-vp9-nexus6.qoe svm-vp9-nexus6-correlate.train

# generate DT training input
./gen_svm_input.sh 0 codec-vp9-nexus6.qoe svm-vp9-nexus6-train.csv
python dtree.py svm-vp9-nexus6-train.csv

# feature selection
python confounder.py svm-vp9-nexus6-train.csv > confound.out
python feature_select.py svm-vp9-nexus6-train.csv.thre9 2 > rfe_feature.out


# plot thread metrics vs. QoE
sh normalize_thread.sh 0 codec-vp9-nexus6.qoe

# plot distribution
sh plot_thread.sh 4000 codec-vp9-nexus6.qoe

# profile futex blocking dependency
sh get_futex_event sorted.all.nexus6.activem.decoded $tid
cat futext_event.$tid1 | python ComputeFutexTime.py $tid2 > $tid1_$tid2.out

# profile binder
sh profile_binder.sh codec-vp9-nexus6-active.tid
sh compute_binder_corr.sh 4000 codec-vp9-nexus6.qoe
