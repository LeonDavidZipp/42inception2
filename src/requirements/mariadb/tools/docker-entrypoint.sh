#!/bin/bash

# Get secrets
export WP_DB_USER_PWD=$(cat /run/secrets/wp_db_user_pwd)

# Start MariaDB server in the background
mysqld_safe --skip-networking &
mariadb_pid=$!

# Wait for MariaDB server to be ready
while ! mysqladmin ping --silent; do
	sleep 1
done

envsubst < /tmp/init.sql > /tmp/init.tmp.sql \
	&& mysql -u root < /tmp/init.tmp.sql \
	&& cat /tmp/init.tmp.sql \
	&& rm -f \
		/tmp/init.tmp.sql \
		/tmp/init.sql \
	&& unset WP_DB_USER_PWD \
	&& echo "Database initialization done"

# Stop the background MariaDB server
mysqladmin shutdown --silent

# Initialize database structure OR upgrade database
mysql_install_db > /dev/null || mysql_upgrade

# Start MariaDB
mysqld
