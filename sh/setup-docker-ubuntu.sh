#!/bin/bash
# Ubuntu setup

apt-get install apt-transport-https ca-certificates

apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 \
    --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list

apt-get update

apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual

apt-get install docker-engine

service docker start