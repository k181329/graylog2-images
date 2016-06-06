#!/bin/bash

set -e

if [ "${1:0:1}" = '-' ]; then
  set -- graylog "$@"
fi

# Create data directories
if [ "$1" = 'graylog' -a "$(id -u)" = '0' ]; then
  for d in journal log plugin config contentpacks; do
    dir=/usr/share/graylog/data/$d
    if [ "$(stat --format='%U:%G' $dir)" != 'graylog:graylog' ]; then
      mkdir -p "$dir"
      chown -R graylog:graylog "$dir"
    fi
  done
  # Start Graylog server
  set -- gosu graylog "$JAVA_HOME/bin/java" $GRAYLOG_SERVER_JAVA_OPTS \
      -jar \
      -Dlog4j.configuration=file:///usr/share/graylog/data/config/log4j2.xml \
      -Djava.library.path=/usr/share/graylog/lib/sigar/ \
      -Dgraylog2.installation_source=docker /usr/share/graylog/graylog.jar \
      server \
      -f /usr/share/graylog/data/config/graylog.conf
fi

# Allow the user to run arbitrarily commands like bash
exec "$@"
