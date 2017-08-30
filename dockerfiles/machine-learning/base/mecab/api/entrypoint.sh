#!/bin/bash

set -eo pipefail

if [ "$1" == "gunicorn" ]; then
    shift
    exec su-exec mecab gunicorn \
        --access-logformat '%(h)s %(l)s %(u)s %(t)s %(D)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"' \
        --access-logfile -  \
        "$@"
fi

exec "$@"