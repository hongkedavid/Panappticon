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
# After installation is done, click "Reboot to system" to reboot
