#! /bin/bash
set -xe

#
# wordpress Version
#
varnishVersion=$1
variant=$2

export DOMAIN="qubestash-test"

CONTAINER_PREFIX=varnish-cache

docker rm -f $(docker ps -a | grep $CONTAINER_PREFIX | awk -F' ' '{print $1}') || true
docker volume rm -f $(docker volume ls -a | awk -F' ' '{print $1}') || true 

# build image
echo "Building for varnish-cache:$varnishVersion"
./update.sh $varnishVersion $variant
# exit 0

docker run --name $CONTAINER_PREFIX-nginx -d nginx

PORT=$((RANDOM + 10000))

docker run --name $CONTAINER_PREFIX-cache \
    --link $CONTAINER_PREFIX-nginx:nginx \
    -p $PORT:80 \
    -e VCL_BACKEND_ADDRESS=nginx \
    -d $(echo $DOMAIN/varnish-cache:$varnishVersion-$variant | sed -e 's/-debian//g')

wget -O - http://localhost:$PORT | grep nginx

docker rm -f $(docker ps -a | grep $CONTAINER_PREFIX | awk -F' ' '{print $1}') || true
docker volume rm -f $(docker volume ls -a | awk -F' ' '{print $1}') || true 