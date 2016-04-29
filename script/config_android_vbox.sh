# Follow http://linus.nci.nih.gov/bdge/installUbuntu.html to install Ubuntu 14.04 on VBox

sudo apt-get install vim git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip abootimg openjdk-7-jdk
  
sudo wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo service udev restart

# http://bernaerts.dyndns.org/linux/74-ubuntu/328-ubuntu-trusty-android-adb-fastboot-qtadb
sudo apt-get install android-tools-adb android-tools-fastboot

mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

git config --global user.name "xxx"
git config --global user.email "xxx@gmail.com"

mkdir panappticon-shamu
cd panappticon-shamu
repo init -u https://android.googlesource.com/platform/manifest -b android-5.1.1_r14
repo sync

# Install Eclipse and Android SDK following http://askubuntu.com/questions/318246/complete-installation-guide-for-android-sdk-adt-bundle-on-ubuntu
cd ~/Downloads
wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
cd ~/Downloads/android-sdk-linux/tools
./android
