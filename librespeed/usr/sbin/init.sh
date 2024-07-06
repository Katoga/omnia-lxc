#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get upgrade --assume-yes

apt-get install --assume-yes --no-install-recommends \
  build-essential \
  git \
  golang \
  prometheus-node-exporter \
  python3 \
  python3-prometheus-client

useradd -UM -s /usr/sbin/nologin librespeed-exporter

readonly librespeed_version=1.0.10
readonly build_script_checksum=821fa881ebbc352ac6808e20462e850a24f3de8df9260976ea8f00de5b46162a475bebcda5d23b20d73f518063fe1bb3d35cf56338503930c52080d8461bb456
mkdir -p /opt/librespeed
cd "/opt/librespeed"
git clone https://github.com/librespeed/speedtest-cli .
git reset --hard "v${librespeed_version}"
echo "${build_script_checksum}  build.sh" | sha512sum -c
./build.sh
mv ./out/librespeed-cli-* /opt/librespeed-exporter/librespeed-cli

mv /opt/librespeed-exporter/librespeed-exporter.service /lib/systemd/system/

systemctl daemon-reload
systemctl start librespeed-exporter
systemctl enable librespeed-exporter
