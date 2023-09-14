#!/bin/sh

_term() {
  kill -TERM "$child" 2>/dev/null
}

trap _term SIGTERM

/bin/envsubst < /etc/config/prometheus_template.yml > /etc/prometheus/prometheus.yml
/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus \
  --web.console.libraries=/usr/share/prometheus/console_libraries \
  --web.console.templates=/usr/share/prometheus/consoles &

child=$!
wait "$child"
