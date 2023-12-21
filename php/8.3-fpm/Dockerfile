FROM php:8.3-fpm-alpine
LABEL Maintainer="Dominik Labudzinski <dominik@labudzinski.com>" \
    Description="PHP-FPM v8.3 with essential extensions on top of Alpine Linux."

ENV PHPIZE_DEPS="git make gcc g++ zlib-dev freetype-dev libjpeg-turbo-dev libpng-dev curl-dev icu-dev libxml2-dev libzip-dev oniguruma-dev imap-dev openssl-dev rabbitmq-c-dev libpng-dev libzip-dev libxslt-dev icu-dev libxml2-dev curl-dev linux-headers libwebp-dev libxpm-dev"
ARG PUID=82
ARG GUID=82
ARG TZ=Europe/Warsaw

RUN apk update
RUN apk upgrade --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main
RUN apk add --no-cache wget ca-certificates curl bzip2 unzip
RUN update-ca-certificates

RUN /bin/sh -c set -eux; \
    apk --update --no-cache  add \
    unzip \
    ca-certificates \
    wget \
    procps \
    openssh \
    gettext \
    libintl \
    imagemagick \
    imagemagick-dev \
    rabbitmq-c \
    libzip \
    icu \
    autoconf \
    gnu-libiconv \
    php83-iconv \
    php83-intl \
    php83-pdo \
    php83-bcmath \
    php83-zip \
    php83-xml \
    php83-opcache \
    php83-mbstring \
    php83-curl  \
    php83-exif \
    php83-sysvmsg \
    php83-sysvsem \
    php83-sysvshm \
    php83-pcntl \
    php83-simplexml \
    php83-fileinfo \
    php83-sockets \
    php83-pecl-amqp \
    php83-pecl-apcu \
    php83-xsl \
    php82-redis \
    php83-pecl-redis \
    php83-bz2 \
    php83-pecl-igbinary \
    php83-pecl-imagick \
    php83-pecl-memcache \
    php83-mysqli \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pgsql \
    php83-pecl-yaml \
    libwebp \
    libjpeg \
    freetype \
    libxpm \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS

# Install gd
RUN ln -s /usr/lib/$(apk --print-arch)-linux-gnu/libXpm.* /usr/lib/ \
    && docker-php-ext-configure gd \
        --enable-gd \
        --with-webp \
        --with-jpeg \
        --with-xpm \
        --with-freetype \
        --enable-gd-jis-conv \
    && docker-php-ext-install -j$(nproc) gd \
    && true

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN set -eux \
    # Fix php.ini settings for enabled extensions
    && chmod +x "$(php -r 'echo ini_get("extension_dir");')"/* \
    # Shrink binaries
    && (find /usr/local/bin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/lib -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/sbin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && true


RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN if [ $PUID != 33 ] ; then apk --no-cache add shadow && usermod -u $PUID www-data && groupmod -g $GUID www-data && mkdir -p /var/www && apk del shadow; fi

RUN mkdir -p /var/www
RUN chown -R www-data:www-data /var/www


RUN rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*

RUN apk del .build-deps $PHPIZE_DEPS imagemagick-dev
EXPOSE 9000
USER www-data
WORKDIR /var/www/html

CMD ["php-fpm"]

# Metadata
LABEL org.opencontainers.image.vendor="Dominik Labudzinski" \
    org.opencontainers.image.url="https://github.com/effiana/docker-images" \
    org.opencontainers.image.title="PHP-FPM v8.3 Alpine" \
    org.opencontainers.image.description="PHP-FPM v8.3 with essential extensions on top of Alpine Linux." \
    org.opencontainers.image.version="8.3" \
    org.opencontainers.image.documentation="https://github.com/effiana/docker-images"