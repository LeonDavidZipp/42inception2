#!/bin/bash

# Get secrets
export WP_DB_USER_PWD=$(cat /run/secrets/wp_db_user_pwd)
echo WP_USER $WP_DB_USER_PWD

# Start MariaDB server in the background
echo "Starting MariaDB for initialization..."
# mariadb-install-db --user=mysql --datadir=/var/lib/mysql
mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
mysqld_safe 

# Wait for MariaDB server to be ready
while ! mysqladmin ping --silent; do
echo "waiting..."
	sleep 1
done

echo "Initializing MariaDB..."
envsubst < /tmp/init.sql > /tmp/init.tmp.sql \
	&& mysql -u root < /tmp/init.tmp.sql \
	&& rm -f \
		/tmp/init.tmp.sql \
		/tmp/init.sql \
	&& unset WP_DB_USER_PWD \
	&& echo "MariaDB initialization done..."

# Stop the background MariaDB server
mysqladmin shutdown --silent

# Initialize database structure OR upgrade database
mysql_install_db > /dev/null 2>&1 || mysql_upgrade > /dev/null 2>&1

# Start MariaDB
echo "Starting MariaDB..."
mysqld