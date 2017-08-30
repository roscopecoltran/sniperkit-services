#!/bin/bash
set -ex

docker run --rm -v "$PWD":/go/src/etcd_v3 -w /go/src/etcd_v3 hub.faas.pro/go-build:alpine go build -o etcd_v3


# build image
# docker build -t hub.faas.pro/func-etcd-v3 .