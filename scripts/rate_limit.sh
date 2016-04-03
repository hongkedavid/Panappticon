# rate limit uplink/downlink traffic rate to some server
tc qdisc add dev wlan0 root handle 1: htb default 30
tc class add dev wlan0 parent 1: classid 1:1 htb rate 1mbit
tc class add dev wlan0 parent 1: classid 1:2 htb rate 1mbit    
tc filter add dev wlan0 protocol ip parent 1:0 prio 1 u32 match ip dst 141.212.110.134/32 flowid 1:1            <
tc filter add dev wlan0 protocol ip parent 1:0 prio 1 u32 match ip src 141.212.110.134/32 flowid 1:2

# show rules
tc -s qdisc

