#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade --assume-yes

# enable mDNS
sed -Ei 's~#?(MulticastDNS=).+$~\1yes~' /etc/systemd/resolved.conf
sed -Ei 's~(\[Network\])~\1\nMulticastDNS=true~' /etc/systemd/network/eth0.network

# install InfluxDB
apt-get install --assume-yes --no-install-recommends \
  curl \
  ca-certificates \
  gnupg

readonly influxdb_gpg_key=influxdata-archive.key
readonly influxdb_gpg_key_checksum=6c2469b4ccd46a53644baa5d201808707ba89cd802f22ba44ec733a60f8d93e235853c5716df9c2ea6ec6b95d0120eeaf5f9bbd0915f09de26f70b131af9d542
mkdir -p /etc/apt/keyrings/
curl -LfSs \
  -o "/tmp/${influxdb_gpg_key}" \
  https://repos.influxdata.com/influxdata-archive.key
echo "${influxdb_gpg_key_checksum} /tmp/${influxdb_gpg_key}" | sha512sum -c
cat "/tmp/${influxdb_gpg_key}" \
| gpg --dearmor \
> /etc/apt/keyrings/influxdata-archive_compat.gpg
echo 'deb [signed-by=/etc/apt/keyrings/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' \
> /etc/apt/sources.list.d/influxdata.list

apt-get update
apt-get install --assume-yes --no-install-recommends \
  influxdb
