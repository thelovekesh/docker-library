ARG PHP_VERSION=8.3

FROM php:${PHP_VERSION}-fpm-trixie

RUN set -ex \
	&& mkdir -p /usr/share/man/man1 /usr/share/man/man7 \
	&& apt-get update -y \
	&& apt-get install -y --no-install-recommends \
	pv jq rsync ssh unzip wget less subversion xfonts-75dpi xfonts-base \
	gnupg2 bzip2 default-mysql-client exiftool git-core imagemagick openssl \
	\
	&& savedAptMark="$(apt-mark showmanual)" \
	\
	&& apt-get install -y --no-install-recommends \
	libxml2-dev libzip-dev libonig-dev libzstd-dev zlib1g-dev \
	libmagickwand-dev libmemcached-dev libpng-dev libssl-dev libwebp-dev \
	libbz2-dev libfreetype6-dev libgmp-dev libicu-dev libjpeg62-turbo-dev \
	\
	# compile and enable PECL extensions
	&& pecl install igbinary \
	&& docker-php-ext-enable igbinary \
	&& pecl install --configureoptions='enable-redis-igbinary="yes" enable-redis-zstd="yes"' redis \
	&& pecl install apcu memcached xdebug imagick \
	&& docker-php-ext-enable apcu redis memcached imagick \
	\
	# compile and enable bundled extensions
	&& docker-php-ext-configure gd --enable-gd --with-jpeg --with-webp --with-freetype \
	&& docker-php-ext-install -j$(nproc) bcmath bz2 calendar exif gettext intl mbstring mysqli opcache pcntl pdo pdo_mysql soap zip gd gmp sockets shmop sysvsem sysvshm \
	\
	# clean up
	&& extDir="$(php -r 'echo ini_get("extension_dir");')" \
	&& apt-mark auto '.*' > /dev/null \
	&& apt-mark manual $savedAptMark \
	&& ldd "$extDir"/*.so \
	| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
	| sort -u \
	| xargs -r dpkg-query --search \
	| cut -d: -f1 \
	| sort -u \
	| xargs -rt apt-mark manual \
	\
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/cache/* /var/lib/log/*

RUN set -ex \
	# install composer
	&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer --2 \
	&& php -r "unlink('composer-setup.php');" \
	# install wp-cli
	&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp \
	# install mailpit
	&& curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash \
	# set www-data as default user
	&& chsh -s /bin/bash www-data \
	&& mkdir -p /var/www/.composer \
	&& chown -R www-data:www-data /var/www

COPY ./xdebug.sh /usr/local/bin/xdebug
COPY ./wp-logs.sh /usr/local/bin/wp-logs
COPY ./setup-wordpress.sh /usr/local/bin/setup-wordpress

RUN chmod +x /usr/local/bin/xdebug /usr/local/bin/wp-logs /usr/local/bin/setup-wordpress
