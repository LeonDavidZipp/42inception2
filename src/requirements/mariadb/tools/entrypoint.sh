#!/bin/bash

# read secrets into temp vars
WP_DB_USER_PWD=$(cat /run/secrets/wp_db_user_pwd)
DB_ROOT_PWD=$(cat /run/secrets/db_root_pwd)

# Ensure the MySQL data directory exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db -u mysql --datadir=/var/lib/mysql
fi

# start db
service mariadb start

# wait till db is running
until mysqladmin ping -u root -p$DB_ROOT_PWD --silent; do
    echo "Waiting for db..."
    sleep 2
done

# init db
sed \
	-e "s/wp_db_user/$WP_DB_USER/g" \
	-e "s/wp_db_user_pwd/$WP_DB_USER_PWD/g" \
	-e "s/wp_db_name/$WP_DB_NAME/g" \
	-e "s/db_root_pwd/$DB_ROOT_PWD/g" \
	./init.sql > /tmp/init.tmp.sql \
	&& mysql -u root -p $DB_ROOT_PWD < /tmp/init.tmp.sql \
	&& rm -f /tmp/init.tmp.sql

# shutdown db
service mariadb stop

# start db in foreground
mysqld_safe

# set -e

# # Ensure the MySQL data directory exists
# if [ ! -d "/var/lib/mysql/mysql" ]; then
#     echo "Initializing MariaDB data directory..."
#     mariadb-install-db --user=mysql --datadir=/var/lib/mysql
# fi

# # Start MariaDB service in the background (without networking)
# echo "Starting MariaDB..."
# mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking & pid="$!"

# # Wait for MariaDB to be available
# echo "Waiting for MariaDB to start..."
# while ! mysqladmin ping --silent; do
#     sleep 1
# done

# sed \
#     -e "s/wp_db_user/$WP_DB_USER/g" \
#     -e "s/wp_db_user_pwd/$WP_DB_USER_PWD/g" \
#     -e "s/wp_db_name/$WP_DB_NAME/g" \
#     -e "s/db_root_pwd/$DB_ROOT_PWD/g" \
#     /app/init.sql > /tmp/init.tmp.sql \
#     && mysql -u root < /tmp/init.tmp.sql \
#     && rm -f /tmp/init.tmp.sql

# # Stop the temporary MariaDB instance
# mysqladmin shutdown

# # Run MariaDB in foreground
# exec mariadbd --user=mysql --datadir=/var/lib/mysql
