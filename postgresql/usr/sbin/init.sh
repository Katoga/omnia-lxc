#!/usr/bin/env sh

set -eu

apk update
apk upgrade
apk add \
  doas \
  icu-data-full \
  postgresql15 \
  postgresql15-jit \
  postgresql15-openrc

rc-service postgresql start

# allow access to all DBs to anyone from local network
echo 'host    all             all        192.168.1.0/24        trust' >> /etc/postgresql/pg_hba.conf

sed -Ei "s~%local_ip_address%~$(hostname -i)~" /etc/postgresql/postgresql.conf

rc-service postgresql restart
rc-update add postgresql

# root may run any command as anyone
echo 'permit nopass keepenv setenv { PATH } root' >> /etc/doas.d/doas.conf
