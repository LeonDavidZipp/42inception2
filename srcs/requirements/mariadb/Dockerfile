FROM debian:bullseye

WORKDIR /app

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y \
	mariadb-server \
	gettext

COPY tools/init.sql /etc/mysql/init.sql
COPY tools/docker-entrypoint.sh /app/docker-entrypoint.sh
COPY tools/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir /run/mysqld

RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]