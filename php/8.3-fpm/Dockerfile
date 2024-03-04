FROM php:8.3-fpm-alpine as php-fpm
LABEL Maintainer="Dominik Labudzinski <dominik@labudzinski.com>" \
    Description="PHP-FPM v8.3 with essential extensions on top of Alpine Linux."

ENV PHPIZE_DEPS="git autoconf make gcc g++ zlib-dev freetype-dev libjpeg-turbo-dev libpng-dev curl-dev icu-dev libxml2-dev libzip-dev oniguruma-dev imap-dev openssl-dev rabbitmq-c-dev libpng-dev libzip-dev libxslt-dev icu-dev libxml2-dev curl-dev linux-headers libwebp-dev libxpm-dev imagemagick-dev"
ARG PUID=82
ARG GUID=82
ARG TZ=Europe/Warsaw

RUN apk update \
    && apk upgrade --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main \
    && /bin/sh -c set -eux; \
    apk --update --no-cache  add \
    wget \
    ca-certificates  \
    curl  \
    bzip2 \
    unzip \
    unzip \
    ca-certificates \
    wget \
    procps \
    shadow \
    openssh \
    gettext \
    libintl \
    imagemagick \
    imagemagick-libs \
    rabbitmq-c \
    libzip \
    icu \
    gnu-libiconv \
    libwebp \
    libxpm \
    libjpeg \
    jpegoptim  \
    optipng \
    pngquant \
    exiftool \
    libxslt \
    tiff \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && update-ca-certificates \
    && curl -sSLf \
               -o /usr/local/bin/install-php-extensions \
               https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions @fix_letsencrypt @composer redis igbinary imagick/imagick@master xsl intl pdo_mysql bcmath soap zip xml opcache mbstring curl  \
    exif mysqli sysvsem sysvmsg sysvshm pcntl simplexml fileinfo curl sockets gd xsl amqp apcu \
    && ln -s /usr/lib/$(apk --print-arch)-linux-gnu/libXpm.* /usr/lib/ \
    && set -eux \
    # Fix php.ini settings for enabled extensions
    && chmod +x "$(php -r 'echo ini_get("extension_dir");')"/* \
    # Shrink binaries
    && (find /usr/local/bin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/lib -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/sbin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && if [ $PUID != 33 ] ; then apk add --no-cache shadow && usermod -u $PUID www-data && groupmod -g $GUID www-data && mkdir -p /var/www && apk del shadow; fi \
    && mkdir -p /var/www \
    && chown -R www-data:www-data /var/www \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && apk del .build-deps $PHPIZE_DEPS \
    && echo 'memory_limit = 512M' > /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo 'upload_max_filesize = 256M' > /usr/local/etc/php/conf.d/docker-php-uploadlimit.ini \
    && echo 'output_buffering = off' > /usr/local/etc/php/conf.d/docker-php-output_buffering.ini \
    && echo 'max_input_time = 300' > /usr/local/etc/php/conf.d/docker-php-max_input_time.ini \
    && echo 'max_execution_time = 300' > /usr/local/etc/php/conf.d/docker-php-max_execution_time.ini \
    && echo 'post_max_size = 256M' > /usr/local/etc/php/conf.d/docker-php-postlimit.ini \
    && mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && true

USER www-data
WORKDIR /var/www/html