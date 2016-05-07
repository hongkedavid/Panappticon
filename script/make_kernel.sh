#Create new boot image
#abootimg -x boot.img
#sed -i '/bootsize =/d' bootimg.cfg
mv zImage-dtb zImage
rm newboot.img
abootimg --create newboot.img -f bootimg.cfg -k zImage -r initrd.img

# Boot using boot image
#adb reboot bootloader
#fastboot flash boot newboot.img

# Flash boot image
#adb reboot bootloader
#fastboot flash boot newboot.img
