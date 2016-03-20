# clone a branch of kernel source code from https://android.googlesource.com/kernel 
git clone https://android.googlesource.com/kernel/msm/ -b android-msm-hammerhead-3.4-lollipop-mr1.1

# build the kernel with netem enabled
echo "CONFIG_NET_SCH_NETEM=y" >> arch/arm/configs/hammerhead_defconfig
make hammerhead_defconfig
make -j32

# clone a branch of Android source code
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
cd msm
cp arch/arm/boot/zImage-dtb android-5.1.1_r14/device/lge/hammerhead-kernel/
cp q_netem.c tc.c Android.mk android-5.1.1_r14/external/iproute2/tc/

# build Android source
source build/envsetup.sh 
lunch (aosp_hammerhead-userdebug)
sudo update-alternatives --config java
sudo update-alternatives --config javac
PATH=/usr/lib/jvm/java-1.7.0-openjdk-amd64/bin/:$PATH
make -j32
