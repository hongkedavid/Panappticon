# generate SVM training input
./gen_svm_input.sh 4000 codec-vp9-nexus6.qoe svm-vp9-nexus6-correlate.train

# scale training data to [0, 1]
./svm-scale -l 0 -u 1 -s range svm-vp9-nexus6-train > svm-vp9-nexus6-train-scale

# compute SVM classifier
./svm-train -s 0 svm-vp9-nexus6-train-scale
