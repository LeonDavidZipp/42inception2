#!/bin/bash

# Get secrets
WP_DB_USER_PWD=$(cat /run/secrets/wp_db_user_pwd)
DB_ROOT_PWD=$(cat /run/secrets/db_root_pwd)

# Start MariaDB server in the background
mysqld_safe --skip-networking &
mariadb_pid=$!

# Wait for MariaDB server to be ready
while ! mysqladmin ping --silent; do
	sleep 1
done

# Run database initialization
sed \
	-e "s/wp_db_user/$WP_DB_USER/g" \
	-e "s/wp_db_user_pwd/$WP_DB_USER_PWD/g" \
	-e "s/wp_db_name/$WP_DB_NAME/g" \
	-e "s/db_root_pwd/$DB_ROOT_PWD/g" \
	/tmp/init.sql > /tmp/init.tmp.sql \
	&& mysql -u root < /tmp/init.tmp.sql \
	&& rm -f \
		/tmp/init.tmp.sql \
		/tmp/init.sql \
	&& echo "Database initialization done"

# Stop the background MariaDB server
mysqladmin shutdown --silent

# Initialize database structure OR upgrade database
mysql_install_db > /dev/null || mysql_upgrade

# Start MariaDB
mysqld