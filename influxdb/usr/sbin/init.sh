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

readonly key_checksum=943666881a1b8d9b849b74caebf02d3465d6beb716510d86a39f6c8e8dac7515
readonly key_name=influxdata-archive
curl -LfSsO "https://repos.influxdata.com/${key_name}.key"
[[ "$(sha256sum ${key_name}.key | cut -d ' ' -f 1)" == "$key_checksum" ]]

cat "${key_name}.key" \
| gpg --dearmor \
> "/etc/apt/keyrings/${key_name}.gpg"

echo "deb [signed-by=/etc/apt/keyrings/${key_name}.gpg] https://repos.influxdata.com/debian stable main" \
>> /etc/apt/sources.list.d/influxdata.list

apt-get update
apt-get install --assume-yes --no-install-recommends \
  influxdb

systemctl daemon-reload
systemctl start influxdb
systemctl enable influxdb
