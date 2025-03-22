## ----------------------------------------------- #
## Base image for the MariaDB container            #
## ----------------------------------------------- #
FROM debian:bullseye
LABEL maintainer="lzipp"

# Set environment variable to suppress prompts
ENV DEBIAN_FRONTEND=noninteractive

# Copy files
COPY tools/init.sql /tmp/init.sql
COPY --chown=mysql:mysql tools/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Update package lists and install MariaDB server
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y \
	mariadb-server \
	gettext \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confold"

RUN mkdir /run/mysqld && chown mysql:mysql /run/mysqld

## Create necessary directories and set permissions
RUN mkdir -p /var/run/mysqld \
 && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql \
 && chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
