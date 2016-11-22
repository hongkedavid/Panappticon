# Download the lates recovery image from https://twrp.me/
# Flash the recovery image to enable boot to recovery mode by following http://androiding.how/how-to-install-twrp-recovery-via-fastboot/
adb reboot bootloader
fastboot flash recovery twrp.img
fastboot reboot

# Download and install OpenGApps from http://wiki.cyanogenmod.org/w/Google_Apps
# Push Open Gapps zip file to the phone and reboot to recovery mode
adb push open_gapps.zip /sdcard/
adb reboot recovery

# Use the default setting (just swipping to confirm and go to next) and Choose "install zip" to install the Open Gapps zip file
# After installation is done, click "Reboot system" to reboot

# In AOSP build, you need to enable "com.google.android.gms" and "com.android.location.fused" by modifying some config files (frameworks/base/core/res/res/values/config.xml and device/moto/shamu/overlay/frameworks/base/core/res/res/values/config.xml) and rebuilding AOSP's framework
# Ref 1: http://jhshi.me/2015/09/23/build-aosp-5-dot-1-1-for-nexus-5/index.html
# Ref 2: http://forum.xda-developers.com/google-nexus-5/help/aosp-build-source-network-positioning-t2743517
