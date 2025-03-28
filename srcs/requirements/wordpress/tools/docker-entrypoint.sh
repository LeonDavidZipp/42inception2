#!/bin/bash

curl -o /usr/local/bin/wp \
	-O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x /usr/local/bin/wp

WP_DB_USER_PWD=$(cat /run/secrets/wp_db_user_pwd)
WP_ADMIN_PWD=$(cat /run/secrets/wp_admin_pwd)
WP_USER_PWD=$(cat /run/secrets/wp_user_pwd)

echo "Checking if WordPress is installed..."
cd /var/www/html
wp core download --allow-root

until nc -z -w50 $WP_DB_HOST 3306
do
	echo "Waiting for MariaDB to start..."
	sleep 1
done

echo "Creating wp-config.php..."
wp config create \
	--dbname=$WP_DB_NAME \
	--dbuser=$WP_DB_USER \
	--dbhost=$WP_DB_HOST \
	--allow-root \
	--quiet \
	--prompt=dbpass < /run/secrets/wp_db_user_pwd

wp core install \
	--url=$WP_DOMAIN \
	--title=$WP_TITLE \
	--admin_user=$WP_ADMIN \
	--admin_email=$WP_ADMIN_EMAIL \
	--allow-root \
	--quiet \
	--prompt=admin_password < /run/secrets/wp_admin_pwd

wp user create \
	$WP_USER \
	$WP_USER_EMAIL \
	--role=author \
	--allow-root \
	--quiet \
	--prompt=user_pass < /run/secrets/wp_user_pwd

chown -R www-data:www-data /var/www/html/

echo "Starting PHP-FPM..."
php-fpm7.4 -F
