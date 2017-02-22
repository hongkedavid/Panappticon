# Change to root user
adb root

# Start a service in an app
adb shell am startservice -n $app/.$service

# Start an activity in an app
adb sehll am start -n -n $app/.$activity
