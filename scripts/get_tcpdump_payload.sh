tcpdump -tt -n -r apprtc_vp8_hd_shamu.tcpdump | grep UDP | grep "35.2.16.193.36943 > 35.2.12.106.34642" > mako_to_shamu.out
cut -d'.' -f1 mako_to_shamu.out > tmp.1
cut -d' ' -f8 mako_to_shamu.out > tmp.2
paste tmp.1 tmp.2 > mako_to_shamu.stat
sed -i 's/\t/ /g' mako_to_shamu.stat
python getDataRate.py mako_to_shamu.stat > mako_to_shamu.sum
sort -n -k1 mako_to_shamu.sum > tmp
mv tmp mako_to_shamu.sum
rm tmp.1 tmp.2
