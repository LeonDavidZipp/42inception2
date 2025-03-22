FROM debian:bullseye
LABEL maintainer="lzipp"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y \
		nginx \
		openssl

RUN mkdir -p /etc/nginx/sites-available \
	&& mkdir -p /etc/nginx/ssl

COPY ./default.cnf /etc/nginx/sites-available/default
COPY certs /etc/nginx/ssl/

RUN chown -R www-data:www-data /etc/nginx/sites-available /etc/nginx/ssl \
	&& chmod -R 755 /etc/nginx/sites-available /etc/nginx/ssl

CMD ["nginx", "-g", "daemon off;"]
