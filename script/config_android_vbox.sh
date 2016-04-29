# Follow http://linus.nci.nih.gov/bdge/installUbuntu.html to install Ubuntu 14.04 on VBox

sudo apt-get install vim git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip abootimg openjdk-7-jdk
  
sudo wget -S -O - http://source.android.com/source/51-android.rules | sed "s/<username>/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo service udev restart

sudo apt-get install android-tools-adb android-tools-fastboot

mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

mkdir panappticon-shamu
git config --global user.name "xxx"
git config --global user.email "xxx@gmail.com"
