#!/bin/bash
id
df -h
free -h
cat /proc/cpuinfo

if [ -d "immortalwrt" ]; then
    echo "repo dir exists"
    cd immortalwrt
    git reset --hard
    git pull || { echo "git pull failed"; exit 1; }
else
    echo "repo dir not exists"
    git clone "https://github.com/immortalwrt/immortalwrt.git" || { echo "git clone failed"; exit 1; }
    cd immortalwrt
fi

cat feeds.conf.default > feeds.conf
echo "" >> feeds.conf
echo "src-git smpackage https://github.com/kenzok8/small-package.git;main" >> feeds.conf
echo "src-git qmodem https://github.com/FUjr/QModem.git;main" >> feeds.conf
#echo "src-git qmodem https://github.com/zzzz0317/QModem.git;stable202508" >> feeds.conf
rm -rf files
cp -r ../files .
if [ -d "package/zz/kmod-fb-tft-gc9307" ]; then
    cd package/zz/kmod-fb-tft-gc9307
    git pull || { echo "kmod-fb-tft-gc9307 git pull failed"; exit 1; }
    cd ../../..
else
    git clone https://github.com/zzzz0317/kmod-fb-tft-gc9307.git package/zz/kmod-fb-tft-gc9307 || { echo "kmod-fb-tft-gc9307 git clone failed"; exit 1; }
fi
if [ -d "package/zz/xgp-v3-screen" ]; then
    cd package/zz/xgp-v3-screen
    git pull || { echo "xgp-v3-screen git pull failed"; exit 1; }
    cd ../../..
else
    git clone https://github.com/zzzz0317/xgp-v3-screen.git package/zz/xgp-v3-screen || { echo "xgp-v3-screen git clone failed"; exit 1; }
fi
