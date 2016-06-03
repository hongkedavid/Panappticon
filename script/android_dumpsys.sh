# Dump memory info
adb shell dumpsys meminfo

# Dump memory info of an activity
adb shell dumpsys meminfo com.google.android.gm

# Dump UI tree of an activity
adb shell dumpsys activity com.google.android.gm

# Dump UI rendering stat of an activity
adb shell dumpsys gfxinfo com.google.android.gm
