#!/bin/bash

# we need to wait for the database to be ready
until nc -z database 5432
do
    echo "waiting for postgres container..."
    sleep 0.5
done

export TYR_CONFIG_FILE=/srv/navitia/settings.py
export PYTHONPATH=.:../navitiacommon

#db migration
python ./manage_tyr.py db upgrade

exec celery beat -A tyr.tasks
