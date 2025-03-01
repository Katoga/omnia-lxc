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

# enable https with self-signed cert
cert_dir=/usr/share/ca-certificates/local/
mkdir -p "$cert_dir"
cert_path="${cert_dir}/grafana.crt"
cert_key_path="${cert_dir}/grafana.key"
cert_csr_path="${cert_dir}/grafana.csr"

openssl genrsa -out "$cert_key_path" 2048
openssl req -new -key "$cert_key_path" -out "$cert_csr_path" -subj '/C=CZ/L=Praha/CN=grafana.local'
openssl x509 -req -days 365 -in "$cert_csr_path" -signkey "$cert_key_path" -out "$cert_path"
chown grafana:grafana "$cert_path"
chown grafana:grafana "$cert_key_path"
chmod 400 "$cert_key_path" "$cert_path"

sed -Ei 's~^;?(protocol =).*$~\1 https~' /etc/grafana/grafana.ini
sed -Ei "s~^;?(cert_file =).*$~\1 ${cert_path}~" /etc/grafana/grafana.ini
sed -Ei "s~^;?(cert_key =).*$~\1 ${cert_key_path}~" /etc/grafana/grafana.ini

# start Grafana server
systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server
