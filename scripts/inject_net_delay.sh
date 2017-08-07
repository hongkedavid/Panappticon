# add (egress) delay rule
tc qdisc add dev wlan0 root netem delay 500ms

# add (egress) rate limit rule
tc qdisc add dev wlan0 root netem rate 1mbit

# rule for (egress) rate limiting, burst control and adding latency
tc qdisc add dev wlan0 root tbf rate 1mbit latency 50ms burst 1540

# add (ingress) delay rule
ip link set dev ifb1 up
tc qdisc add dev wlan0 handle ffff: ingress
tc filter add dev wlan0 parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev ifb1
tc qdisc add dev ifb1 handle 1: root netem delay 500ms

# add (egress) rate limit rule (tbf is not available by default)
tc qdisc add dev rmnet0 root handle 1: htb default 1
tc class add dev rmnet0 parent 1: classid 1:1 htb rate 200kbit burst 20k

# add (ingress) rate limit rule (tbf is not available by default)
tc qdisc add dev rmnet0 handle ffff: ingress
tc filter add dev rmnet0 parent ffff: protocol ip u32 match ip src 0.0.0.0/0 police rate 200kbit burst 20k drop flowid :1

# show rules
tc -s qdisc
tc -s qdisc ls dev wlan0

# clear (egress) rules
tc qdisc del dev wlan0 root netem

# clear (ingress) rules
tc qdisc del dev wlan0 root
tc qdisc del dev ifb1 root
