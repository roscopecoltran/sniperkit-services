#!/bin/sh
set -x
set -e

# Set temp environment vars
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin
export BUILDPATH=${GOPATH}/src/github.com/blippar/git2etcd
export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

# Install build deps
apk --no-cache --no-progress --virtual build-deps add go gcc musl-dev make cmake openssl-dev libssh2-dev

# Install libgit2
./docker/install-libgit2.sh

# Init go environment to build git2etcd
mkdir -p $(dirname ${BUILDPATH})
ln -s /app ${BUILDPATH}
cd ${BUILDPATH}
go get -v
go build

# Cleanup GOPATH
rm -r ${GOPATH}

# Remove build deps
apk --no-cache --no-progress del build-deps