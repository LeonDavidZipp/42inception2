# ----------------------------------------------- #
# Base image for the MariaDB container            #
# ----------------------------------------------- #
FROM debian:11 as base

LABEL maintainer="lzipp"

# copy needed files
# COPY ./50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY ./tools/init.sql ./
COPY ./tools/entrypoint.sh /usr/local/bin/.

# install mariadb and other needed packages
RUN apt-get update \
	&& apt-get upgrade \
	&& apt-get install -y \
		mariadb-server \
		sed

# create needed directories and set permissions
RUN mkdir -p /var/run/mysqld /var/lib/mysql \
	&& chown -R mysql:mysql /var/run/mysqld /var/lib/mysql \
	&& chmod +x /usr/local/bin/entrypoint.sh

# use default config but allow remote connections
RUN sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

CMD ["/usr/local/bin/entrypoint.sh"]
