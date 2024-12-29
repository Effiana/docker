ARG ALPINE_VERSION=3
ARG DEBUG=0

FROM php:8.4-zts-alpine as BUILDER
ARG PHP_VERSION=84
ARG UNIT_VERSION=1.32.1
ARG PUID=1001
ARG GUID=1001
ARG TZ=Europe/Warsaw

RUN set -ex \
    && apk add --no-cache --update \
    openssl-dev curl gcc git musl-dev make linux-headers pcre2 pcre2-dev \
    && mkdir -p /usr/lib/unit/modules /usr/lib/unit/debug-modules \
    && mkdir -p /usr/src/unit \
    && cd /usr/src/unit \
    && git clone --depth 1 -b 1.33.0-1 https://github.com/nginx/unit \
    && cd unit \
    && NCPU="$(getconf _NPROCESSORS_ONLN)" \
    && CONFIGURE_ARGS_MODULES="--prefix=/usr \
                    --statedir=/var/lib/unit \
                    --control=unix:/var/run/control.unit.sock \
                    --runstatedir=/var/run \
                    --pid=/var/run/unit.pid \
                    --logdir=/var/log \
                    --log=/var/log/unit.log \
                    --tmpdir=/var/tmp \
                    --user=unit \
                    --group=unit \
                    --openssl \
                    --libdir=/usr/lib" \
    && CONFIGURE_ARGS="$CONFIGURE_ARGS_MODULES \
                    --njs" \
    && make -j $NCPU -C pkg/contrib .njs \
    && export PKG_CONFIG_PATH=$(pwd)/pkg/contrib/njs/build \
    && ./configure $CONFIGURE_ARGS --cc-opt="$CC_OPT" --ld-opt="$LD_OPT" --modulesdir=/usr/lib/unit/debug-modules --debug \
    && make -j $NCPU unitd \
    && install -pm755 build/sbin/unitd /usr/sbin/unitd-debug \
    && make clean \
    && ./configure $CONFIGURE_ARGS --modulesdir=/usr/lib/unit/modules \
    && make -j $NCPU unitd \
    && install -pm755 build/sbin/unitd /usr/sbin/unitd \
    && make clean \
    && /bin/true \
    && ./configure $CONFIGURE_ARGS_MODULES --cc-opt="$CC_OPT" --modulesdir=/usr/lib/unit/debug-modules --debug \
    && ./configure php \
    && make -j $NCPU php-install \
    && make clean \
    && ./configure $CONFIGURE_ARGS_MODULES --cc-opt="$CC_OPT" --modulesdir=/usr/lib/unit/modules \
    && ./configure php \
    && make -j $NCPU php-install \
    && cd \
    && rm -rf /usr/src/unit \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories \
    && echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade --available \
    && apk --update --no-cache  add \
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
    && update-ca-certificates \
    && apk add --no-cache --update \
        tini ca-certificates curl pcre2 musl openssl shadow php83-embed \
    && mkdir -p /var/lib/unit/ \
    && mkdir /docker-entrypoint.d/ \
    && curl -sSLf \
               -o /usr/local/bin/install-php-extensions \
               https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions imagick @fix_letsencrypt @composer gmp sodium redis iconv igbinary xsl intl pdo_mysql bcmath soap zip xml opcache mbstring curl  \
    exif mysqli sysvsem sysvmsg sysvshm pcntl excimer simplexml fileinfo curl sockets gd xsl amqp apcu pgsql pdo_pgsql \
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
      --gecos "unit user" \
      --shell /bin/false \
      www-data \
    && if [ $PUID != 33 ] ; then usermod -u $PUID www-data && groupmod -g $GUID www-data && mkdir -p /var/www; fi \
    && ldconfig / \
    && chown -R ${PUID}:${GUID} /run /var/lib/unit /usr/lib/unit \
    && ln -sf /dev/stderr /var/log/unit.log \
    && mkdir -p /var/www \
    && chown -R www-data:www-data /var/www \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && echo 'memory_limit = 2048M' > /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo 'upload_max_filesize = 2048M' > /usr/local/etc/php/conf.d/docker-php-uploadlimit.ini \
    && echo 'output_buffering = off' > /usr/local/etc/php/conf.d/docker-php-output_buffering.ini \
    && echo 'max_input_time = 300' > /usr/local/etc/php/conf.d/docker-php-max_input_time.ini \
    && echo 'max_execution_time = 300' > /usr/local/etc/php/conf.d/docker-php-max_execution_time.ini \
    && echo 'post_max_size = 2048M' > /usr/local/etc/php/conf.d/docker-php-postlimit.ini \
    && mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && apk del openssl-dev gcc musl-dev make linux-headers pcre2-dev \
    && true

STOPSIGNAL SIGTERM
USER ${PUID}:${GUID}
ENTRYPOINT ["/usr/sbin/unitd"]
EXPOSE 80
CMD ["--no-daemon", "--log", "/dev/stdout", "--control", "unix:/var/run/control.unit.sock"]

WORKDIR /var/www/html