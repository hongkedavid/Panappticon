# Android-5.1.1 factory image

./flash-base.sh
fastboot flash recovery recovery.img
fastboot flash boot boot.img
fastboot flash system system.img
fastboot flash cache cache.img

# Erase user data if executed
# fastboot flash userdata userdata.img

fastboot reboot
