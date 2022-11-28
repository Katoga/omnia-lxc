#!/usr/bin/env sh

set -eu

apk update
apk upgrade
apk add \
  mariadb \
  mariadb-client \
  mariadb-openrc

sed -Ei "s~%bind_address%~$(hostname -i)~" /etc/my.cnf.d/zz-mariadb-local.cnf

/etc/init.d/mariadb setup

rc-service mariadb start
rc-update add mariadb

# create custom DB superuser for remote connect
db_username=maria
db_password="$(head -c 1000 /dev/urandom | tr -dc 'a-z0-9' | head -c 64)"
echo "GRANT ALL PRIVILEGES ON *.* to '${db_username}'@'%' IDENTIFIED BY '${db_password}' WITH GRANT OPTION;" \
  | mysql
echo "FLUSH PRIVILEGES;" \
  | mysql
echo -e "generated password for user '${db_username}':\n${db_password}\n"
