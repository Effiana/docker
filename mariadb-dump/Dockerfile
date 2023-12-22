FROM alpine:latest
RUN apk add --update mariadb-client bash openssh-client && rm -rf /var/cache/apk/*
COPY mariadb-dump/dump.sh /usr/bin/dump
RUN chmod +x /usr/bin/dump

ENTRYPOINT ["/usr/bin/dump"]