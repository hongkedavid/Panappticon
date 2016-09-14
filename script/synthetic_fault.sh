# Stress CPU
stress --cpu 64 --timeout 15s   

# Slow down sdcard read speed based on http://www.androidpolice.com/2011/04/04/increase-your-sd-card-read-speeds-by-100-200-with-a-simple-tweak-hands-on-benchmarks/ and http://www.techrepublic.com/blog/tablets-in-the-enterprise/increase-the-read-write-speed-of-the-sd-card-on-your-rooted-android-tablet/
echo 4 > /sys/devices/virtual/bdi/179\:0/read_ahead_kb

# Inject network delay
tc qdisc add dev wlan0 root netem delay 1000ms
tc qdisc del dev wlan0 root netem     
