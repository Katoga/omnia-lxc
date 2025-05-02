#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade --assume-yes
apt-get install --assume-yes --no-install-recommends \
  ca-certificates \
  curl

# enable mDNS
sed -Ei 's~#?(MulticastDNS=).+$~\1yes~' /etc/systemd/resolved.conf
sed -Ei 's~(\[Network\])~\1\nMulticastDNS=true~' /etc/systemd/network/eth0.network

# install go
readonly go_version=1.24.2
readonly go_checksum=ff72215e0bb9d801029455b36e606c8fd145e828e071ff458a0766a8fc2b73f8a72fd8a474687d2322ace97061b18374b445b32bd0a1c688ba9a43065885a674

readonly go_tarball="go${go_version}.linux-armv6l.tar.gz"
curl -LfSsO "https://go.dev/dl/${go_tarball}"
echo "${go_checksum}  ${go_tarball}" \
| sha512sum -c --strict

rm -rf /usr/local/go
tar -C /usr/local -xzf "$go_tarball"

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
. ~/.profile

# install speedtest-cli
readonly speedtest_cli_version=1.0.11
go install "github.com/librespeed/speedtest-cli@v${speedtest_cli_version}"
mv ~/go/bin/speedtest-cli /usr/local/bin/

# install librespeed_exporter
readonly librespeed_exporter_version=0.6.0
go install "github.com/Katoga/librespeed_exporter@v${librespeed_exporter_version}"
mv ~/go/bin/librespeed_exporter /usr/local/bin/

# start librespeed_exporter service
useradd -UM -s /usr/sbin/nologin librespeed-exporter
mv /opt/librespeed-exporter/librespeed-exporter.service /lib/systemd/system/
systemctl daemon-reload
systemctl start librespeed-exporter
systemctl enable librespeed-exporter
