# clone a branch of kernel source code from https://android.googlesource.com/kernel 
# Nexus 5 and Android 5.1.1 as an example
git clone https://android.googlesource.com/kernel/msm/ -b android-msm-hammerhead-3.4-lollipop-mr1.1

# build the kernel with netem enabled
echo "CONFIG_NET_SCH_NETEM=y" >> arch/arm/configs/hammerhead_defconfig
make hammerhead_defconfig
make -j32

# clone a branch of Android source code based on https://source.android.com/source/build-numbers.html
make android-5.1.1_r14
cd android-5.1.1_r14/
repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.1_r14
repo sync

# download and install driver binary from https://developers.google.com/android/nexus/drivers
cd android-5.1.1_r14/
wget https://dl.google.com/dl/android/aosp/broadcom-hammerhead-lmy48m-5d6ca8e6.tgz
wget https://dl.google.com/dl/android/aosp/lge-hammerhead-lmy48m-0759ba99.tgz
wget https://dl.google.com/dl/android/aosp/qcom-hammerhead-lmy48m-b7143e92.tgz
tar xf broadcom-hammerhead-lmy48m-5d6ca8e6.tgz
tar xf lge-hammerhead-lmy48m-0759ba99.tgz
tar xf qcom-hammerhead-lmy48m-b7143e92.tgz
./extract-broadcom-hammerhead.sh  
./extract-lge-hammerhead.sh  
./extract-qcom-hammerhead.sh

# replace the kernel (location can be found at https://source.android.com/source/building-kernels.html) and tc source file
cd msm/
cp arch/arm/boot/zImage-dtb android-5.1.1_r14/device/lge/hammerhead-kernel/
cp tc/q_netem.c tc/tc.c tc/Android.mk android-5.1.1_r14/external/iproute2/tc/

# build Android source
cd android-5.1.1_r14/
source build/envsetup.sh 
lunch (aosp_hammerhead-userdebug)
sudo update-alternatives --config java
sudo update-alternatives --config javac
PATH=/usr/lib/jvm/java-1.7.0-openjdk-amd64/bin:$PATH
make -j32

# flash the Android build to device
cd android-5.1.1_r14/
adb reboot bootloader
fastboot flashall -w

# Install kernel ref: http://softwarebakery.com/building-the-android-kernel-on-linux

# Fix Android javadoc compilation error on tehran, refer to this
# http://stackoverflow.com/questions/18777479/android-4-3-build-error
# http://askubuntu.com/questions/159575/how-do-i-make-java-default-to-a-manually-installed-jre-jdk

# Add javadoc
sudo update-alternatives --install /usr/bin/javadoc javadoc /usr/lib/jvm/jdk1.6.0_45/bin/javadoc 2

# Fix java version revert after "lunch"
# export PATH=/usr/lib/jvm/java-6-oracle/bin:$PATH

# Install tc
mmm external/iproute2/tc
adb push out/target/product/maguro/system/bin/tc /sdcard/tc
cat /sdcard/tc > /system/bin/tc
