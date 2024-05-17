#!/usr/bin/env bash

set -euo pipefail

apt-get update
apt-get upgrade --assume-yes

apt-get install --assume-yes --no-install-recommends \
  apt-transport-https \
  curl \
  gnupg \
  software-properties-common

mkdir -p /etc/apt/keyrings/

curl -LfSs https://apt.grafana.com/gpg.key \
| gpg --dearmor \
> /etc/apt/keyrings/grafana.gpg

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" >> /etc/apt/sources.list.d/grafana.list

apt-get update
apt-get install --assume-yes --no-install-recommends \
  grafana

# enable https with self-signed cert
cert_path=/etc/grafana/grafana.crt
cert_key_path=/etc/grafana/grafana.key

openssl genrsa -out "$cert_key_path" 2048
openssl req -new -key "$cert_key_path" -out /etc/grafana/grafana.csr -subj '/C=CZ/L=Praha/CN=grafana.lan'
openssl x509 -req -days 365 -in /etc/grafana/grafana.csr -signkey "$cert_key_path" -out "$cert_path"
chown grafana:grafana "$cert_path"
chown grafana:grafana "$cert_key_path"
chmod 400 "$cert_key_path" "$cert_path"

sed -Ei 's~;protocol = http~protocol = https~' /etc/grafana/grafana.ini
sed -Ei 's~;domain = localhost~domain = grafana.lan~' /etc/grafana/grafana.ini
sed -Ei "s~;cert_file =~cert_file =${cert_path}~" /etc/grafana/grafana.ini
sed -Ei "s~;cert_key =~cert_key =${cert_key_path}~" /etc/grafana/grafana.ini

# disable call-home
sed -Ei 's~;reporting_enabled = true~reporting_enabled = false~' /etc/grafana/grafana.ini

# activate
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
