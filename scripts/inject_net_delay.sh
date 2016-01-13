# add delay rule
tc qdisc add dev wlan0 root netem delay 500ms

# add rate limit rule
tc qdisc add dev wlan0 root netem rate 1mbit

# show rules
tc -s qdisc

# clear rules
tc qdisc del dev wlan0 root netem
