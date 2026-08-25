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
readonly go_version=1.27.0
readonly go_checksum=8282b7d73b7bdc3409822a3ed8ea751a0ffa1eb9759e4e87a2893bf752ee9626fd5e5e59c51cc713bde9196f2ee3e66b7eec99199091e8633691d041bd65ec17

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
readonly speedtest_cli_version=1.0.13
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
