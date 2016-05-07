# Android-5.1.1 factory image
adb reboot bootloader

#./flash-base.sh 
fastboot flash bootloader bootloader-shamu-moto-apq8084-71.10.img
fastboot reboot-bootloader
fastboot flash radio radio-shamu-d4.0-9625-02.101.img
fastboot reboot-bootloader

fastboot flash cache cache.img

fastboot flash recovery recovery.img
fastboot flash boot boot.img
fastboot flash system system.img

# Erase user data if executed
# fastboot flash userdata userdata.img

fastboot reboot
