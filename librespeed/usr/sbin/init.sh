#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade --assume-yes
apt-get install --assume-yes --no-install-recommends \
  ca-certificates \
  curl

# enable mDNS
mkdir -p /etc/systemd/resolved.conf.d/
echo -e '[Resolve]\nMulticastDNS=yes' >> /etc/systemd/resolved.conf.d/mdns.conf
sed -Ei 's~(\[Network\])~\1\nMulticastDNS=true~' /etc/systemd/network/eth0.network

# install go
readonly go_version=1.27.1
readonly go_checksum=d74a25ec52250a84e77b8fa8db607203c639476d755558fa3da10ee6697b3fac651508d085f1394af3cb758f8ecaf95678da17c0e9887de51fbf7b27d72e43b6

readonly go_tarball="go${go_version}.linux-armv6l.tar.gz"
curl -LfSsO "https://go.dev/dl/${go_tarball}"
echo "${go_checksum}  ${go_tarball}" \
| sha512sum -c --strict

rm -rf /usr/local/go
tar -C /usr/local -xzf "$go_tarball"

# shellcheck disable=SC2016
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
# shellcheck source=/dev/null
. ~/.profile

# install speedtest-cli
readonly speedtest_cli_version=1.0.14
go install "github.com/librespeed/speedtest-cli@v${speedtest_cli_version}"
mv ~/go/bin/speedtest-cli /usr/local/bin/

# install librespeed_exporter
readonly librespeed_exporter_version=0.14.0
go install "github.com/Katoga/librespeed_exporter@v${librespeed_exporter_version}"
mv ~/go/bin/librespeed_exporter /usr/local/bin/

# start librespeed_exporter service
useradd -UM -s /usr/sbin/nologin librespeed-exporter
mv /opt/librespeed-exporter/librespeed-exporter.service /lib/systemd/system/
systemctl daemon-reload
systemctl start librespeed-exporter
systemctl enable librespeed-exporter
