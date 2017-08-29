#!/bin/sh
set -x
set -e

# Set temp environment vars
export APK_BUILD_CUSTOM=${APK_BUILD_CUSTOM:-"git openssl ca-certificates libssh2 make gcc g++ musl-dev curl tar \
											go go-cross-darwin go-tools go-cross-windows"}
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin
export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

export KRAKEND_VCS_URI=${KRAKEND_VCS_URI:-"github.com/devopsfaith/krakend"}
export KRAKEND_VCS_BRANCH=${KRAKEND_VCS_BRANCH:-"master"}
export KRAKEND_VCS_DEPTH=${KRAKEND_VCS_DEPTH:-"1"}
export KRAKEND_VCS_CLONE_PATH=${GOPATH}/src/${KRAKEND_VCS_URI}

apk add --no-cache --no-progress --update --virtual .build-deps ${APK_BUILD_CUSTOM}

go get -v github.com/Masterminds/glide
go get -v github.com/mitchellh/gox

# Compile & Install libgit2 (v0.23)
git clone -b ${KRAKEND_VCS_BRANCH} --depth ${KRAKEND_VCS_DEPTH} -- https://${KRAKEND_VCS_URI} ${KRAKEND_VCS_CLONE_PATH}

mkdir -p /shared/apps
ln -s /shared/apps/demos ${KRAKEND_VCS_CLONE_PATH}/examples
cd ${KRAKEND_VCS_CLONE_PATH}
pwd
ls -l 

make all

find /shared/apps -name "Makefile" | sed 's/Makefile//g' | while read dir; do cd ${dir}; make all; cd -; done

cd /scripts
./install-searx-admin.sh

# Cleanup GOPATH
rm -r ${GOPATH}

apk del .build-deps
