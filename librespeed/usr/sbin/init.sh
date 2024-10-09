#!/usr/bin/env bash

set -euo pipefail

readonly speedtest_cli_version=1.0.11
readonly librespeed_exporter_version=0.3.2

apt-get update
apt-get upgrade --assume-yes

useradd -UM -s /usr/sbin/nologin librespeed-exporter

apt-get install --assume-yes --no-install-recommends \
  build-essential \
  curl \
  ca-certificates \
  git \
  prometheus-node-exporter

readonly go_version="$(curl -LfSs https://go.dev/VERSION?m=text | head -n1)"

curl -LfSsO "https://go.dev/dl/${go_version}.linux-armv6l.tar.gz"
rm -rf /usr/local/go && tar -C /usr/local -xzf "${go_version}.linux-armv6l.tar.gz"

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
. ~/.profile

go install "github.com/librespeed/speedtest-cli@v${speedtest_cli_version}"
mv ~/go/bin/speedtest-cli /usr/local/bin/

go install "github.com/Katoga/librespeed_exporter@v${librespeed_exporter_version}"
mv ~/go/bin/librespeed_exporter /usr/local/bin/

mv /opt/librespeed-exporter/librespeed-exporter.service /lib/systemd/system/

systemctl daemon-reload
systemctl start librespeed-exporter
systemctl enable librespeed-exporter
