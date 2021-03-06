# Ref at http://softwarebakery.com/building-the-android-kernel-on-linux
# Extract a boot image (available from facotry image or out/target/product/xx/boot.img in Android build)
#abootimg -x boot.img
#sed -i '/bootsize =/d' bootimg.cfg

# Create new boot image (arch/arm/boot/zImage or arch/arm/boot/zImage-dtb)
mv zImage-dtb zImage
rm newboot.img
abootimg --create newboot.img -f bootimg.cfg -k zImage -r initrd.img

# Boot using boot image (not flashed)
#adb reboot bootloader
#fastboot boot newboot.img

# Flash boot image
adb reboot bootloader
fastboot flash boot newboot.img

# Enable dmesg to get printk output
su
echo 0 > /proc/sys/kernel/dmesg_restrict
