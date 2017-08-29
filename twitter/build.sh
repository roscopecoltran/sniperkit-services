#!/bin/bash
set -ex

docker run --rm -v "$PWD":/go/src/twitter -w /go/src/twitter hub.faas.pro/go-build:alpine go build -o twitter

# build image
# docker build -t hub.faas.pro/func-twitter .