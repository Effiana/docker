FROM nginx:mainline-alpine-slim

ARG PUID=82
ARG GUID=82
ARG TZ=Europe/Warsaw

RUN apk --no-cache add shadow
RUN usermod -l www-data nginx
RUN usermod -u $PUID www-data && groupmod -g $GUID www-data


RUN apk del shadow

RUN mkdir -p /var/www/html/public
RUN chown -R www-data:www-data /var/www
RUN chown -R www-data:www-data /var/cache/nginx
RUN chown -R www-data:root /var/run/
RUN chown -R www-data:www-data /var/log/
RUN chmod -R 777 /var/log

COPY nginx/nginx.conf /etc/nginx/nginx.conf

USER www-data
WORKDIR /var/www/html/public