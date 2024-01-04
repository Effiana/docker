FROM nginx:mainline-alpine-slim

LABEL Maintainer="Dominik Labudzinski <dominik@labudzinski.com>" \
    Description="Nginx with essential extensions on top of Alpine Linux."

ARG PUID=82
ARG GUID=82
ARG TZ=Europe/Warsaw

RUN apk --no-cache add shadow \
    && usermod -l www-data nginx \
    && usermod -u $PUID www-data && groupmod -g $GUID www-data \
    && apk del shadow \
    && mkdir -p /var/www/html/public \
    && chown -R www-data:www-data /var/www \
    && chown -R www-data:www-data /var/cache/nginx \
    && chown -R www-data:root /var/run/ \
    && chown -R www-data:www-data /var/log/ \
    && chmod -R 777 /var/log

COPY nginx/nginx.conf /etc/nginx/nginx.conf

USER www-data
WORKDIR /var/www/html/public