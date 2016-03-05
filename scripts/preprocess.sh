# profile thread metrics
sh filter_proc_tid.sh sorted.all.nexus6.activem.decoded 2278 > codec-vp9-nexus6-active.tid
sh profile_cpu_lock.sh

# compute thread-qoe correlation
sh compute_thread_corr.sh 4000 codec-vp9-nexus6.qoe

# generate SVM/DT training input
./gen_svm_input.sh 4000 codec-vp9-nexus6.qoe svm-vp9-nexus6-correlate.train

# get all thread IDs
sh get_thread_id.sh sorted.all.nexus6.activem.decoded

sh plot_thread.sh 4000 codec-vp9-nexus6.qoe
