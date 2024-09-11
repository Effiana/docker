FROM unit:php8.3
LABEL Maintainer="Dominik Labudzinski <dominik@labudzinski.com>" \
    Description="PHP-FPM v"${PHP_VERSION}" with essential extensions on top of Alpine Linux."

ARG PUID=1001
ARG GUID=1001
ARG TZ=Europe/Warsaw
RUN sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list \
    && apt update  \
    && apt-mark hold usrmerge \
    && apt-mark hold usr-is-merged \
    && apt upgrade --without-new-pkgs -y && apt full-upgrade -y && apt dist-upgrade -y && apt install vim -y  \
    && curl -sSLf \
       -o /usr/local/bin/install-php-extensions \
       https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions amqp apcu csv @composer decimal lz4 uuid redis igbinary imagick/imagick@master xsl intl pdo_mysql bcmath zip xml opcache mbstring curl  \
           exif sysvsem sysvmsg sysvshm pcntl simplexml fileinfo sockets gd pgsql pdo_pgsql \
    && set -eux \
    # Fix php.ini settings for enabled extensions
    && chmod +x "$(php -r 'echo ini_get("extension_dir");')"/* \
    # Shrink binaries
    && (find /usr/local/bin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/lib -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/sbin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && usermod -u $PUID www-data && groupmod -g $GUID www-data \
    && mkdir -p /var/www \
    && chown -R www-data:www-data /var/www \
    && rm -rf /tmp/* \
    && echo 'memory_limit = 512M' > /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo 'upload_max_filesize = 256M' > /usr/local/etc/php/conf.d/docker-php-uploadlimit.ini \
    && echo 'output_buffering = off' > /usr/local/etc/php/conf.d/docker-php-output_buffering.ini \
    && echo 'max_input_time = 300' > /usr/local/etc/php/conf.d/docker-php-max_input_time.ini \
    && echo 'max_execution_time = 300' > /usr/local/etc/php/conf.d/docker-php-max_execution_time.ini \
    && echo 'post_max_size = 256M' > /usr/local/etc/php/conf.d/docker-php-postlimit.ini \
    && mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && true

WORKDIR /var/www/html