#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade --assume-yes

# enable mDNS
sed -Ei 's~#?(MulticastDNS=).+$~\1yes~' /etc/systemd/resolved.conf
sed -Ei 's~(\[Network\])~\1\nMulticastDNS=true~' /etc/systemd/network/eth0.network

# install Grafana
apt-get install --assume-yes --no-install-recommends \
  apt-transport-https \
  gnupg \
  software-properties-common \
  wget

mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key \
| gpg --dearmor \
> /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
> /etc/apt/sources.list.d/grafana.list

apt-get update
apt-get install --assume-yes --no-install-recommends \
  grafana

# configure Grafana
sed -Ei 's~^;?(domain =).*$~\1 grafana.local~' /etc/grafana/grafana.ini

# disable call-home, see https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#analytics
sed -Ei 's~;?(reporting_enabled|check_for_updates|check_for_plugin_updates)\s*.+~\1 = false~' /etc/grafana/grafana.ini

systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server
