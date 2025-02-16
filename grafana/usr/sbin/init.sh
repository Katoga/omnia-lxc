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
