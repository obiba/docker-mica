#!/bin/bash
set -e

if [ "$1" = 'app' ]; then
    if [ "$(id -u)" = 0 ]; then
        chown -R mica:mica "$MICA_HOME"
        exec gosu mica /opt/mica/bin/start.sh
    fi
    exec /opt/mica/bin/start.sh
fi

exec "$@"
