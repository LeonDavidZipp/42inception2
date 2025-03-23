#!/bin/bash

set -e

# export WP_DB_PWD=$(cat /run/secrets/wp_db_pwd)
export WP_DB_ROOT_PWD=$(cat /run/secrets/wp_db_root_pwd)
export WP_DB_USER_PWD=$(cat /run/secrets/wp_db_user_pwd)

envsubst < /etc/mysql/init.sql > /tmp/init.tmp.sql

mysql_install_db
mysqld
