# !/bin/sh
# teardown.sh

stop.sh

alias_exists() {
  count=$(ifconfig lo0 | grep $DOCKERHOST_ALIAS_IP | wc -l)
  [ $count == 1 ]
}

if alias_exists ; then
  echo 'Removing network interface...'
  sudo ifconfig lo0 -alias $DOCKERHOST_ALIAS_IP &> /dev/null
else
  echo 'No network interface configured'
fi

docker rm -v demo-db  &> /dev/null
docker rm -v demo-elk  &> /dev/null
docker rm -v demo-memcached  &> /dev/null
docker rm -v demo-nginx  &> /dev/null
docker rm -v demo-redis  &> /dev/null

docker volume rm volume rm dockerdemostack_elk-data  &> /dev/null
docker volume rm volume rm dockerdemostack_redis-data  &> /dev/null
