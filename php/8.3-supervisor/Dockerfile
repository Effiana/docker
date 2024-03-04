FROM ghcr.io/surnet/alpine-wkhtmltopdf:3.19.0-0.12.6-full as wkhtmltopdf
FROM effiana/php-8.3-fpm:latest
LABEL Maintainer="Dominik Labudzinski <dominik@labudzinski.com>" \
    Description="PHP-FPM v8.3 with supervisord"

USER root
RUN apk add --no-cache  \
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
    && rm -rf /tmp/* /var/cache/apk/* \
    && mkdir -p /var/www  \
    && chown -R www-data:www-data /var/www \
    && chown -R www-data:www-data /var/log/ \
    && chown -R www-data:www-data /run/

COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/libwkhtmltox.so /bin/
COPY ./php/8.3-supervisor/supervisord.conf /etc/supervisord.conf
RUN chown www-data:www-data /etc/supervisord.conf

USER www-data
ENTRYPOINT ["docker-php-entrypoint"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]