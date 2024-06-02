FROM ghcr.io/surnet/alpine-wkhtmltopdf:3.20.0-0.12.6-full as wkhtmltopdf
FROM php:8.3-zts-alpine
LABEL Maintainer="Dominik Labudzinski <dominik@labudzinski.com>" \
    Description="PHP v8.3 with supervisord"
COPY ./php/8.3-supervisor/supervisord.conf /etc/supervisord.conf
ARG PUID=1001
ARG GUID=1001
ARG TZ=Europe/Warsaw
USER root
RUN apk add --no-cache  \
    pcre2 \
    tzdata  \
    java-jre  \
    bash  \
    ffmpeg  \
    ghostscript  \
    libstdc++ \
    libx11 \
    libxrender \
    libxext \
    ca-certificates \
    fontconfig \
    freetype \
    ttf-droid \
    ttf-freefont \
    ttf-liberation \
    supervisor \
    exiftool \
    shadow \
    && curl -sSLf \
       -o /usr/local/bin/install-php-extensions \
       https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions @fix_letsencrypt @composer sodium redis iconv igbinary imagick/imagick@master xsl intl pdo_mysql bcmath soap zip xml opcache mbstring curl  \
      exif mysqli sysvsem sysvmsg sysvshm pcntl simplexml fileinfo curl sockets gd xsl amqp apcu \
    && ln -s /usr/lib/$(apk --print-arch)-linux-gnu/libXpm.* /usr/lib/ \
    && (ln -s /usr/local/bin/php /usr/bin/php || true) \
    && (ln -s /usr/local/bin/phar /usr/bin/phar || true) \
    && (ln -s /usr/local/bin/phar.phar /usr/bin/phar.phar || true) \
    && mkdir -p /usr/local/etc/ \
    && (ln -s /etc/php /usr/local/etc/php || true) \
    && groupdel -f www-data \
    && userdel www-data \
    && addgroup --system www-data \
    && adduser \
      --system \
      --disabled-password \
      --ingroup www-data \
      --no-create-home \
      --home /nonexistent \
      --gecos "www-data user" \
      --shell /bin/false \
      www-data \
    && if [ $PUID != 33 ] ; then usermod -u $PUID www-data && groupmod -g $GUID www-data && mkdir -p /var/www; fi \
    && ldconfig / \
    && mkdir -p /var/www \
    && chown -R www-data:www-data /var/www \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && echo 'memory_limit = 512M' > /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo 'upload_max_filesize = 256M' > /usr/local/etc/php/conf.d/docker-php-uploadlimit.ini \
    && echo 'output_buffering = off' > /usr/local/etc/php/conf.d/docker-php-output_buffering.ini \
    && echo 'max_input_time = 300' > /usr/local/etc/php/conf.d/docker-php-max_input_time.ini \
    && echo 'max_execution_time = 300' > /usr/local/etc/php/conf.d/docker-php-max_execution_time.ini \
    && echo 'post_max_size = 256M' > /usr/local/etc/php/conf.d/docker-php-postlimit.ini \
    && mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && apk del gcc \
    && true \
    && rm -rf /tmp/* /var/cache/apk/* \
    && mkdir -p /var/www  \
    && chown -R www-data:www-data /var/www \
    && chown -R www-data:www-data /var/log/ \
    && chown -R www-data:www-data /run/ \
    && chown www-data:www-data /etc/supervisord.conf \
    && chmod g+wx /var/log/
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/libwkhtmltox.so /bin/

USER www-data
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]