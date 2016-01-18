tcpdump -i wlan0 -n ip "dst host $1" -T rtp -w /sdcard/$2.tcpdump

tcpdump -tt -r /sdcard/$2.tcpdump
