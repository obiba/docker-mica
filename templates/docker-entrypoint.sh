#!/bin/bash
set -e

if [ "$1" = 'app' ]; then
    chown -R mica "$MICA_HOME"

    exec gosu mica /opt/mica/bin/start.sh
fi

exec "$@"
