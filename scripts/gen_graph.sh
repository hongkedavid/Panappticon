mkdir graph/$1;
mkdir graph/$1/transactions;
for f in $(ls result/$1/transactions/UI_INPUT*);
do
   file=$(echo $f | cut -d'/' -f4 | cut -d'.' -f1);
   python DebugUtil.py $f 0 > graph/$1/transactions/$file.graph;
done
