#!/usr/bin/env sh

set -eu

# enable IPv4 networking
# https://wiki.turris.cz/en/public/lxc_alpine
mount -t proc proc proc/
ifconfig eth0 192.168.1.160 netmask 255.255.255.0 up
route add default gw 192.168.1.1
echo "nameserver 192.168.1.1" > /etc/resolv.conf

apk update

apk add --upgrade apk-tools
apk upgrade --available

apk add \
  bash \
  git \
  go \
  openrc \
  py3-prometheus-client \
  python3

rc-update add networking
rc-update add bootmisc boot

# build librespeed
readonly librespeed_version=1.0.10
readonly build_script_checksum=821fa881ebbc352ac6808e20462e850a24f3de8df9260976ea8f00de5b46162a475bebcda5d23b20d73f518063fe1bb3d35cf56338503930c52080d8461bb456
mkdir -p /opt/librespeed
cd "/opt/librespeed"
git clone https://github.com/librespeed/speedtest-cli .
git reset --hard "v${librespeed_version}"
echo "${build_script_checksum}  build.sh" | sha512sum -c
./build.sh
mv ./out/librespeed-cli-* /opt/librespeed-exporter/librespeed-cli

adduser -D librespeed

rc-update add librespeed-exporter default
