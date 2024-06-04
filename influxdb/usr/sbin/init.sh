#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get upgrade --assume-yes

apt-get install --assume-yes --no-install-recommends \
  apt-transport-https \
  curl \
  gnupg \
  prometheus-node-exporter \
  software-properties-common

mkdir -p /etc/apt/keyrings/

readonly key_checksum=393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c
curl -LfSsO https://repos.influxdata.com/influxdata-archive_compat.key
[[ "$(sha256sum influxdata-archive_compat.key | cut -d ' ' -f 1)" == "$key_checksum" ]]

cat influxdata-archive_compat.key \
| gpg --dearmor \
> /etc/apt/keyrings/influxdata-archive_compat.gpg

echo 'deb [signed-by=/etc/apt/keyrings/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' \
>> /etc/apt/sources.list.d/influxdata.list

apt-get update
apt-get install --assume-yes --no-install-recommends \
  influxdb

systemctl daemon-reload
systemctl start influxdb
systemctl enable influxdb
