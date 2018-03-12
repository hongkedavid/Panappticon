# Ref: https://www.kernel.org/doc/Documentation/cpu-freq/user-guide.txt
su
echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "interactive" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "interactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo "interactive" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

# Nexus 4 maximum CPU frequencey
echo 1512000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1512000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo 1512000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
echo 1512000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq

cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor   
cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq    

# Nexus 6 maximum CPU frequencey
echo 2649600 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 2649600 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo 2649600 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
echo 2649600 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
