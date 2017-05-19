s=""; for f in $(cat msqrd.logcat | grep MeshHelper | cut -d'(' -f2 | cut -d')' -f1 | sed 's/ //g' | sort | uniq); do s="$f\|$s"; done; 
#s=""; for f in $(cat msqrd.logcat | grep MeshHelper | cut -c19-24 | sed 's/ //g' | sort | uniq); do s="$f\|$s"; done; 
s="$sTouchEvent"; cat msqrd.logcat | grep "$s" | grep "CameraControl\|TouchEvent\|MeshHelper" > msqrd.logcat.time
nl=$(cat msqrd.logcat.time | wc -l)
cat msqrd.logcat.time | grep TouchEvent | cut -d' ' -f2 | sed 's/://g' | sed 's/\.//g' > msqrd.logcat.tmp.1
cat msqrd.logcat.time | grep "Face is" | cut -d' ' -f2 | sed 's/://g' | sed 's/\.//g' > msqrd.logcat.tmp.2
for ((i=4;i<=$nl;i=i+8)); do cat msqrd.logcat.time | head -n$i | tail -n1 | cut -d' ' -f2 | sed 's/://g' | sed 's/\.//g'; done > msqrd.logcat.tmp.4
for ((i=5;i<=$nl;i=i+8)); do cat msqrd.logcat.time | head -n$i | tail -n1 | cut -d':' -f4 | cut -d' ' -f5 | cut -d'm' -f1; done > msqrd.logcat.tmp.5
for ((i=6;i<=$nl;i=i+8)); do cat msqrd.logcat.time | head -n$i | tail -n1 | cut -d':' -f4 | cut -d' ' -f5 | cut -d'm' -f1; done > msqrd.logcat.tmp.6
for ((i=7;i<=$nl;i=i+8)); do cat msqrd.logcat.time | head -n$i | tail -n1 | cut -d':' -f4 | cut -d' ' -f5 | cut -d'm' -f1; done > msqrd.logcat.tmp.7
paste msqrd.logcat.tmp.1 msqrd.logcat.tmp.4 msqrd.logcat.tmp.2 msqrd.logcat.tmp.5 msqrd.logcat.tmp.6 msqrd.logcat.tmp.7 > msqrd.logcat.tmp.3
awk '{print $2-$1"\t"$3-$2"\t"$4+$5+$6"\t"$3-$1}' msqrd.logcat.tmp.3 > msqrd.logcat.tmp.8
cat msqrd.logcat.time | grep TouchEvent | cut -d' ' -f2 > msqrd.logcat.tmp.1
cat msqrd.logcat.time | grep "Face is" | cut -d' ' -f2 > msqrd.logcat.tmp.2
for ((i=4;i<=$nl;i=i+8)); do cat msqrd.logcat.time | head -n$i | tail -n1 | cut -d' ' -f2; done > msqrd.logcat.tmp.4
paste msqrd.logcat.tmp.1 msqrd.logcat.tmp.4 msqrd.logcat.tmp.2 msqrd.logcat.tmp.8 > msqrd.logcat.time.stat
rm msqrd.logcat.tmp*
