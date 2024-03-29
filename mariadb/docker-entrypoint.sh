#!/bin/sh

if [ -d /var/lib/mysql/mysql ]; then
  echo "[i] MySQL directory already present, skipping DB creation."
else
  # Execute any pre-init scripts, useful for images
  # based on this image
  for i in /opt/mariadb/pre-init.d/*sh; do
    if [ -f "${i}" ]; then
      echo "[i] pre-init.d - processing $i..."
      /bin/sh "${i}"
    fi
  done

  echo "[i] MySQL data directory is not found, creating initial DB(s)..."
  mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql --defaults-file=/etc/mysql/my.cnf >/dev/null

  if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
    MYSQL_ROOT_PASSWORD=$(pwgen 16 1)
    echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
  fi

  MYSQL_DATABASE=${MYSQL_DATABASE:-""}
  MYSQL_USER=${MYSQL_USER:-""}
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}

  tfile=$(mktemp)

  cat <<EOF >"$tfile"
DELETE FROM mysql.user WHERE host = '$(hostname)';
DELETE FROM mysql.proxies_priv WHERE host = '$(hostname)';
FLUSH PRIVILEGES;
CREATE USER 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD";
CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD";
CREATE USER 'root'@'::1' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD";
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'::1' WITH GRANT OPTION;
ALTER USER 'root'@'127.0.0.1' IDENTIFIED BY '';
ALTER USER 'root'@'::1' IDENTIFIED BY '';
EOF

  if [ "$MYSQL_DATABASE" != "" ]; then
    echo "[i] Creating database: $MYSQL_DATABASE"
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >>"$tfile"
  fi

  if [ "$MYSQL_USER" != "" ]; then
    echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD..."
    echo "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >>"$tfile"

    if [ "$MYSQL_DATABASE" != "" ]; then
      echo "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%';" >>"$tfile"
    fi
  fi
  echo "FLUSH PRIVILEGES;" >>"$tfile"

  /usr/bin/mysqld --defaults-file=/etc/mysql/my.cnf --console --user=mysql --bootstrap <"$tfile" || exit 1
  rm -f "$tfile"

  # Execute any post-init scripts, useful for images
  # based on this image
  for i in /opt/mariadb/post-init.d/*sh; do
    if [ -f "${i}" ]; then
      echo "[i] post-init.d - processing $i..."
      /bin/sh "${i}"
    fi
  done
fi

# Execute any pre-exec scripts, useful for images
# based on this image
for i in /opt/mariadb/pre-exec.d/*sh; do
  if [ -f "${i}" ]; then
    echo "[i] pre-exec.d - processing $i..."
    /bin/sh "${i}"
  fi
done

exec /usr/bin/mysqld --defaults-file=/etc/mysql/my.cnf --user=mysql --console