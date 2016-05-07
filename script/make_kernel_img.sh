# Ref at http://softwarebakery.com/building-the-android-kernel-on-linux
# Extract a boot image
#abootimg -x boot.img
#sed -i '/bootsize =/d' bootimg.cfg

# Create new boot image
mv zImage-dtb zImage
rm newboot.img
abootimg --create newboot.img -f bootimg.cfg -k zImage -r initrd.img

# Boot using boot image (not flashed)
#adb reboot bootloader
#fastboot boot newboot.img

# Flash boot image
adb reboot bootloader
fastboot flash boot newboot.img
