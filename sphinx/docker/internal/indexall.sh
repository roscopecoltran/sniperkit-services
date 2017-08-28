#!/bin/sh

#echo "wain-for-it $DB_HOST:$DB_PORT"
#./wait-for-it.sh $DB_HOST:$DB_PORT
echo "=====> sleep 5"
sleep 5

echo "=====> indexer --rotate --all"
indexer --all --rotate "$@"

echo "=====> searchd"
exec searchd --nodetach "$@"
