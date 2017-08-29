#!/bin/sh
set -x
set -e

# Set temp environment vars
export APK_BUILD_CUSTOM=${APK_BUILD_CUSTOM:-"git openssl ca-certificates libssh2 make gcc g++ musl-dev curl tar tree \
											go go-cross-darwin go-tools go-cross-windows"}
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin
export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

export ETCD_VCS_URI=${ETCD_VCS_URI:-"github.com/coreos/etcd"}
export ETCD_VCS_BRANCH=${ETCD_VCS_BRANCH:-"master"}
export ETCD_VCS_DEPTH=${ETCD_VCS_DEPTH:-"1"}
export ETCD_VCS_CLONE_PATH=${GOPATH}/src/${ETCD_VCS_URI}

apk add --no-cache --no-progress --update --virtual .build-deps ${APK_BUILD_CUSTOM}

go get -v github.com/Masterminds/glide
go get -v github.com/mitchellh/gox

# Compile & Install libgit2 (v0.23)
git clone -b ${ETCD_VCS_BRANCH} --depth ${ETCD_VCS_DEPTH} -- https://${ETCD_VCS_URI} ${ETCD_VCS_CLONE_PATH}

cd ${ETCD_VCS_CLONE_PATH}
pwd
ls -l 
glide install --strip-vendor

# cross-build available binaries to /shared/apps/dist
gox -os="linux darwin" -arch="amd64" -output="/shared/apps/dist/{{.Dir}}/{{.Dir}}_{{.OS}}_{{.Arch}}" $(glide novendor)
tree /shared/apps/dist/etcd

# copy to /usr/local/sbin/ all generated binaries for alpine linux
gox -os="linux darwin" -arch="amd64" -output="/usr/local/sbin/{{.Dir}}" $(glide novendor)

# Cleanup GOPATH
rm -Rf ${GOPATH}/

apk del .build-deps

