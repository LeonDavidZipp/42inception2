FROM debian:bullseye
LABEL maintainer="lzipp"

# Set environment variable to suppress prompts
ENV DEBIAN_FRONTEND=noninteractive

# Copy files
COPY tools/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Update package lists and install PHP and PHP-FPM
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y \
		php7.4-fpm \
		php7.4-mysqli \
		php7.4-curl \
		php7.4-gd \
		php7.4-intl \
		php7.4-mbstring \
		php7.4-imagick \
		php7.4-dom \
		php7.4-zip \
		curl \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confold" \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Create necessary directories
RUN mkdir -p /run/php

# Create necessary directories and set permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
CMD ["/usr/local/bin/docker-entrypoint.sh"]