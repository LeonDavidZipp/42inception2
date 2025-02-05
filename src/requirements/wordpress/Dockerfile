FROM debian:stable-slim
LABEL maintainer="lzipp"

# Set environment variable to suppress prompts
ENV DEBIAN_FRONTEND=noninteractive

# Copy files
COPY tools/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Update package lists and install PHP and PHP-FPM
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y \
		php8.2-fpm \
		php8.2-mysqli \
		php8.2-curl \
		php8.2-gd \
		php8.2-intl \
		php8.2-mbstring \
		php8.2-imagick \
		php8.2-dom \
		php8.2-zip \
		curl \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confold" \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

# Create necessary directories and set permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
CMD ["/usr/local/bin/docker-entrypoint.sh"]