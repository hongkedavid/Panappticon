# unsorted_file
cp $1 tmp;
awk '{printf "%d\t%s\n", NR, $0}' < tmp > tmp.tmp;
sed -i 's/\t/ /g' tmp.tmp;
sed -i 's/:/ /g' tmp.tmp;
sed -i 's/,/ /g' tmp.tmp;
sed -i 's/}/ /g' tmp.tmp;
cut -d' ' -f6,8 tmp.tmp > tmp.tmp.tmp
paste tmp.tmp.tmp tmp > tmp.tmp;
sed -i 's/\t/ /g' tmp.tmp;
sort -n -k 1,1 -k 2,2 tmp.tmp | cut -d' ' -f3- > sorted.$1;
rm tmp tmp.tmp tmp.tmp.tmp;
