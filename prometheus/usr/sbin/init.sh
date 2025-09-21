#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade --assume-yes

# enable mDNS
mkdir -p /etc/systemd/resolved.conf.d/
echo -e '[Resolve]\nMulticastDNS=yes' >> /etc/systemd/resolved.conf.d/mdns.conf
sed -Ei 's~(\[Network\])~\1\nMulticastDNS=true~' /etc/systemd/network/eth0.network

# install Prometheus
apt-get install --assume-yes --no-install-recommends \
  prometheus
cp -f /opt/prometheus/prometheus.yml /etc/prometheus/prometheus.yml
systemctl reload prometheus
