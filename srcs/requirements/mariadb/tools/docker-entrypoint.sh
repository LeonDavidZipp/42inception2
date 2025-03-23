#!/bin/bash

set -e

# export WP_DB_PWD=$(cat /run/secrets/wp_db_pwd)
export WP_DB_ROOT_PWD=$(cat /run/secrets/wp_db_root_pwd)
export WP_DB_USER_PWD=$(cat /run/secrets/wp_db_user_pwd)

echo "WP db name: a"$WP_DB_NAME"a"
echo "WP db user: a"$WP_DB_USER"a"
echo "WP db user pwd: a"$WP_DB_USER_PWD"a"
echo "WP db user pwd: a"$WP_DB_ROOT_PWD"a"
echo "WP db host: a"$WP_DB_HOST"a"
envsubst < /etc/mysql/init.sql > /tmp/init.tmp.sql
echo catting
cat /tmp/init.tmp.sql

mysql_install_db
# rm -rf /tmp/init.tmp.sql
mysqld