#!/bin/sh
set -x
set -e

# Set temp environment vars
export APK_BUILD_CUSTOM=${APK_BUILD_CUSTOM:-"git make gcc g++ musl-dev tree go go-tools"}
# go-cross-windows go-cross-darwin 
export GOPATH=/tmp/go
export PATH=${PATH}:${GOPATH}/bin
export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

export ETCD_VCS_URI=${ETCD_VCS_URI:-"github.com/coreos/etcd"}
export ETCD_VCS_BRANCH=${ETCD_VCS_BRANCH:-"master"}
export ETCD_VCS_DEPTH=${ETCD_VCS_DEPTH:-"1"}
export ETCD_VCS_CLONE_PATH=${GOPATH}/src/${ETCD_VCS_URI}

apk add --no-cache --no-progress --update --virtual .build-deps ${APK_BUILD_CUSTOM}

go get -v github.com/Masterminds/glide
export GLIDE_HOME=/tmp/glide_home
export GLIDE_TMP=/tmp/glide_tmp
mkdir -p ${GLIDE_TMP}
mkdir -p ${GLIDE_HOME}

go get -v github.com/mitchellh/gox

# Compile & Install libgit2 (v0.23)
git clone -b ${ETCD_VCS_BRANCH} --depth ${ETCD_VCS_DEPTH} -- https://${ETCD_VCS_URI} ${ETCD_VCS_CLONE_PATH}

cd ${ETCD_VCS_CLONE_PATH}
pwd
ls -l 
glide install --strip-vendor

# cross-build available binaries to /shared/apps/dist
# gox -os="linux" -arch="amd64" -output="/shared/apps/dist/{{.Dir}}/{{.Dir}}_{{.OS}}_{{.Arch}}" $(glide novendor)
# tree /shared/apps/dist/etcd

# copy to /usr/local/sbin/ all generated binaries for alpine linux
gox -os="linux" -arch="amd64" -output="/usr/local/sbin/{{.Dir}}" $(glide novendor)

# Cleanup GOPATH
rm -Rf ${GOPATH}
rm -Rf ${GLIDE_HOME}
rm -Rf ${GLIDE_TMP}

apk del .build-deps

