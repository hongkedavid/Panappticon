adb shell ls /sdcard/$tid.*.tracedump | tr '\r' ' ' | xargs -n1 adb pull
