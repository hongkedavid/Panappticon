# add delay rule
tc qdisc add dev wlan0 root netem delay 500ms

# show rules
tc -s qdisc

# clear rules
tc qdisc del dev wlan0 root netem
