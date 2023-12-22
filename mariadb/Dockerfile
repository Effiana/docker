FROM alpine:latest
LABEL Maintainer="Dominik Labudzinski <dominik@labudzinski.com>" \
    Description="MaridDB with essential extensions on top of Alpine Linux."

# Install packages and cleanup in a single step
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
        pwgen \
        openssl \
        ca-certificates \
        mariadb \
        mariadb-client \
        mariadb-server-utils && \
    update-ca-certificates && \
    mkdir -p /var/lib/mysql \
             /run/mysqld \
             /etc/mysql/conf.d \
             /opt/mariadb/pre-init.d \
             /opt/mariadb/post-init.d \
             /opt/mariadb/pre-exec.d && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld /opt/mariadb && \
    chmod -R 755 /opt/mariadb && \
    sed -i 's/^.*auth_pam_tool_dir.*$/#auth_pam_tool_dir not exists/' /usr/bin/mysql_install_db

# Add scripts and configuration files
COPY mariadb/docker-entrypoint.sh /scripts/docker-entrypoint.sh
COPY mariadb/conf/my.cnf /etc/mysql/my.cnf

# Create a directory for initialization scripts
RUN mkdir /docker-entrypoint-initdb.d && \
    chmod -R 755 /scripts

# Expose the MySQL port
EXPOSE 3306

# Define a volume for MySQL data
VOLUME ["/var/lib/mysql"]

# Set the entrypoint command
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]

# Metadata
LABEL org.opencontainers.image.vendor="Dominik Labudzinski" \
    org.opencontainers.image.url="https://github.com/effiana/docker" \
    org.opencontainers.image.title="MariaDB Alpine" \
    org.opencontainers.image.description="MariaDB with essential extensions on top of Alpine Linux." \
    org.opencontainers.image.version="1.0" \
    org.opencontainers.image.documentation="https://github.com/effiana/docker"
