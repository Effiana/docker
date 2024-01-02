ARG TARGETARCH=amd64

FROM alpine:3.15 as base-amd64
RUN echo ${TARGETARCH}
ARG ARCH="linux-x86_64"


FROM alpine:3.15 as base-arm64
RUN echo ${TARGETARCH}
ARG ARCH="linux-aarch64"

FROM base-${TARGETARCH} as base
LABEL Maintainer="Dominik Labudzinski <dominik@labudzinski.com>" \
    Description="Elastic 8.9.2 with essential extensions on top of Alpine Linux."

RUN apk add --no-cache openjdk17-jre-headless su-exec

ENV VERSION 8.9.2
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/elasticsearch"
ENV ES_TARBAL "${DOWNLOAD_URL}/elasticsearch-${VERSION}-${ARCH}.tar.gz"

RUN apk add --no-cache bash
RUN apk add --no-cache -t .build-deps wget ca-certificates gnupg openssl \
  && set -ex \
  && cd /tmp \
  && echo "===> Install Elasticsearch..." \
  && wget --progress=bar:force -O elasticsearch.tar.gz "$ES_TARBAL"; \
  tar -xf elasticsearch.tar.gz \
  && ls -lah \
  && mv elasticsearch-$VERSION /usr/share/elasticsearch \
  && adduser -D -h /usr/share/elasticsearch elasticsearch \
  && echo "===> Creating Elasticsearch Paths..." \
  && for path in \
  /usr/share/elasticsearch/data \
  /usr/share/elasticsearch/logs \
  /usr/share/elasticsearch/config \
  /usr/share/elasticsearch/config/scripts \
  /usr/share/elasticsearch/tmp \
  /usr/share/elasticsearch/plugins \
  ; do \
  mkdir -p "$path"; \
  chown -R elasticsearch:elasticsearch "$path"; \
  done \
  && rm -rf /tmp/* /usr/share/elasticsearch/jdk \
  && apk del --purge .build-deps

# TODO: remove this (it removes X-Pack ML so it works on Alpine)
RUN rm -rf /usr/share/elasticsearch/modules/x-pack-ml/platform/${ARCH}

COPY elastic/8.9/config/elastic /usr/share/elasticsearch/config
COPY elastic/8.9/config/logrotate /etc/logrotate.d/elasticsearch
COPY elastic/8.9/elastic-entrypoint.sh /
RUN chmod +x /elastic-entrypoint.sh
COPY elastic/8.9/docker-healthcheck /usr/local/bin/

WORKDIR /usr/share/elasticsearch

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV ES_TMPDIR /usr/share/elasticsearch/tmp

VOLUME ["/usr/share/elasticsearch/data"]

EXPOSE 9200 9300
ENTRYPOINT ["/elastic-entrypoint.sh"]
CMD ["elasticsearch"]

HEALTHCHECK CMD ["docker-healthcheck"]
