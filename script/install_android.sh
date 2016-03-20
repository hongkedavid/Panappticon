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
./

# build Android source
cp zImage device/
source build/envsetup.sh 
lunch (full_hammerhead-userdebug)
make -j32
