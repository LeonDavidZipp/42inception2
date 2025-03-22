#!/bin/bash

# Create config if it doesn't exist
cd /var/www/html
wp core download --allow-root

WP_DB_USER_PWD=$(cat /run/secrets/wp_db_user_pwd)
WP_ADMIN_PWD=$(cat /run/secrets/wp_admin_pwd)
WP_USER_PWD=$(cat /run/secrets/wp_user_pwd)

echo "Creating wp-config.php..."
echo $WP_DB_NAME
echo $WP_DB_USER
echo $WP_DB_USER_PWD
echo $WP_DB_HOST
echo $WP_DB_USER_PWD
echo $WP_ADMIN_PWD
echo $WP_USER_PWD

until nc -z -w50 $WP_DB_HOST 3306
do
	echo "Waiting for MariaDB to start..."
	sleep 1
done

# wp config create \
# 	--dbname="${WP_DB_NAME}" \
# 	--dbuser="${WP_DB_USER}" \
# 	--dbhost="${WP_DB_HOST}" \
# 	--dbprefix="${WP_DB_PREFIX}" \
# 	--force \
# 	--allow-root \
# 	--prompt=dbpass < /run/secrets/wp_db_user_pwd

wp config create \
	--dbname=$WP_DB_NAME \
	--dbuser=$WP_DB_USER \
	--dbhost=$WP_DB_HOST \
	--allow-root \
	--quiet \
	--prompt=dbpass < /run/secrets/wp_db_user_pwd

# echo "Checking if WordPress is installed..."
# if ! wp core is-installed --allow-root; then
# 	echo "Installing WordPress core..."
# 	wp core install \
# 		--url="${WP_DOMAIN}" \
# 		--title="${WP_TITLE}" \
# 		--admin_user="${WP_ADMIN}" \
# 		--admin_email="${WP_ADMIN_EMAIL}" \
# 		--admin_password="${WP_ADMIN_PWD}" \
# 		--allow-root
# else
# 	echo "WordPress is already installed. Skipping core installation."
# fi

wp core install \
	--url=$WP_DOMAIN \
	--title=$WP_TITLE \
	--admin_user=$WP_ADMIN \
	--admin_email=$WP_ADMIN_EMAIL \
	--allow-root \
	--quiet \
	--prompt=admin_password < /run/secrets/wp_admin_pwd

# if ! wp user get "${WP_USER}" --field=ID --allow-root > /dev/null 2>&1; then
# 	echo "Creating user ${WP_USER}..."
# 	wp user create \
# 		"${WP_USER}" \
# 		"${WP_USER_EMAIL}" \
# 		--user_pass="${WP_USER_PWD}" \
# 		--allow-root
# else
# 	echo "User ${WP_USER} already exists. Skipping user creation."
# fi

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