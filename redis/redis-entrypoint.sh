#!/bin/sh
set -e

CONF="/usr/local/etc/redis/redis.conf"

if [ -n "${REDIS_PASSWORD:-}" ]; then
  exec redis-server "$CONF" --requirepass "$REDIS_PASSWORD"
fi

exec redis-server "$CONF"

