#!/usr/bin/env sh

set -eu

apk update
apk upgrade
apk add \
  redis \
  redis-openrc

echo -e '\ninclude /etc/redis-local.conf' >> /etc/redis.conf

sed -Ei "s~%local_ip_address%~$(hostname -i)~" /etc/redis-local.conf

rc-service redis start
rc-update add redis
