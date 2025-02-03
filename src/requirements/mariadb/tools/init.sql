CREATE USER IF NOT EXISTS 'wp_db_user'@'%' IDENTIFIED BY 'wp_db_user_pwd';
CREATE DATABASE IF NOT EXISTS wp_db_name;
GRANT ALL PRIVILEGES ON wp_db_name.* TO 'wp_db_user'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY 'db_root_pwd';
FLUSH PRIVILEGES;