FROM debian:bullseye

RUN apt-get update \
	&& apt-get upgrade \
	&& apt-get install -y nginx \
	&& mkdir -p /etc/nginx/sites-available \
	&& mkdir -p /etc/nginx/ssl

COPY ./default.cnf /etc/nginx/sites-available/default.cnf
COPY ./certs /etc/nginx/ssl/

CMD ["nginx", "-g", "daemon off;"]
