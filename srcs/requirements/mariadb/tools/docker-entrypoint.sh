#!/bin/bash

set -e

# Check if MariaDB is already initialized or needs initialization
if [ -f "var/lib/mysql/already_initialized" ]; then
    echo "MariaDB is already initialized. Skipping setup..."
else
    if [ ! -d "var/lib/mysql/mysql" ]; then
        echo "Installing MariaDB Database..."
        mysql_install_db --user=mysql --datadir=/var/lib/mysql
    fi

    # start MariaDB & wait for it to be ready
    echo "Starting MariaDB for initialization..."
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    until mysqladmin ping --silent; do
        echo "waiting..."
        sleep 1
    done

    # Initialize database structure OR upgrade database
    echo "Initializing MariaDB..."
    export WP_DB_USER_PWD=$(cat /run/secrets/db_user_pwd)
    envsubst < /tmp/init.sql > /tmp/init.tmp.sql \
        && mysql -u root < /tmp/init.tmp.sql \
        && rm -f \
            /tmp/init.tmp.sql \
            /tmp/init.sql
    unset WP_DB_USER_PWD

    echo "MariaDB initialization done. Shutting down MariaDB initialization instance..."
    export DB_ROOT_PWD=$(cat /run/secrets/db_root_pwd)
    mysqladmin -u root -p${DB_ROOT_PWD} shutdown --silent
    unset DB_ROOT_PWD
    touch var/lib/mysql/already_initialized
    echo "MariaDB setup done."
fi

echo "Starting MariaDB..."
mysqld --user=mysql --datadir=/var/lib/mysql