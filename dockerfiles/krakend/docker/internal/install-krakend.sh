#!/bin/sh
set -x
set -e

clear
echo

### GOLANG ####################################################################################################

export GOPATH=/go
export PATH=${PATH}:${GOPATH}/bin
export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

### PROJECT ####################################################################################################

export KRAKEND_VCS_URI=${KRAKEND_VCS_URI:-"github.com/devopsfaith/krakend"}

export KRAKEND_VCS_BRANCH=${KRAKEND_VCS_BRANCH:-"master"}
export KRAKEND_VCS_DEPTH=${KRAKEND_VCS_DEPTH:-"1"}

export KRAKEND_VCS_CLONE_PATH=${GOPATH}/src/${KRAKEND_VCS_URI}
export KRAKEND_BUILD_DATE=${KRAKEND_BUILD_DATE:-"$BUILD_DATE"}

### COMMON ####################################################################################################

DIR=$(dirname "$0")
echo "$DIR"
if [ -f ${DIR}/common.sh ]; then
	. ${DIR}/common.sh
fi
pwd

### ENV #######################################################################################################

# Set temp environment vars
export APK_BUILD_GOLANG=${APK_BUILD_GOLANG:-"go git openssl ca-certificates libssh2 make"}
export APK_BUILD_GOLANG_CGO=${APK_BUILD_GOLANG_CGO:-"gcc g++ musl-dev"}
export APK_BUILD_GOLANG_TOOLS=${APK_BUILD_GOLANG_TOOLS:-"go-tools"}
export APK_BUILD_GOLANG_CROSS=${APK_BUILD_GOLANG_CROSS:-"go-cross-darwin go-cross-windows go-cross-freebsd go-cross-openbsd"}

### APK #######################################################################################################

apk add --no-cache --no-progress --update --virtual .go-deps ${APK_BUILD_GOLANG}
apk add --no-cache --no-progress --update --virtual .cgo-deps ${APK_BUILD_GOLANG_CGO}
apk add --no-cache --no-progress --update --virtual .go-tools-deps ${APK_BUILD_GOLANG_TOOLS}
apk add --no-cache --no-progress --update --virtual .go-cross-deps ${APK_BUILD_GOLANG_CROSS}

### GOX #######################################################################################################

go get -v ${GOX_VCS_URI:-"github.com/mitchellh/gox"}

### VCS #######################################################################################################

# Compile & Install libgit2 (v0.23)
git clone -b ${KRAKEND_VCS_BRANCH} --depth ${KRAKEND_VCS_DEPTH} -- https://${KRAKEND_VCS_URI} ${KRAKEND_VCS_CLONE_PATH}
cd ${KRAKEND_VCS_CLONE_PATH}
pwd
ls -l 
export KRAKEND_VCS_VERSION=$(git ${BUILD_VCS_VERSION_ARGS:-"describe --always --long --dirty --tags"})

### GLIDE #####################################################################################################

# ref(s):
#  -  https://github.com/Masterminds/glide
go get -v ${GLIDE_VCS_URI:-"github.com/Masterminds/glide"}
export GLIDE_HOME=${GLIDE_HOME:-"$GOPATH/glide_home"}
export GLIDE_TMP=${GLIDE_TMP:-"$GOPATH/glide_tmp"}
export GLIDE_BACKUP_DIR=${GLIDE_BACKUP_DIR:-"/shared/conf.d/deps/glide"}
export GLIDE_CONF_FN=${GLIDE_CONF_FN:-"glide.yaml"}
export GLIDE_LOCK_FN=${GLIDE_LOCK_FN:-"glide.lock"}
mkdir -p ${GLIDE_TMP}
mkdir -p ${GLIDE_HOME}

if [ ! -f ${GLIDE_CONF_FN} ]; then
	yes no | glide create 
fi
if [ -f ${GLIDE_CONF_FN} ]; then
	glide install ${GLIDE_INSTALL_ARGS:-""}
fi

mkdir -p ${GLIDE_BACKUP_DIR}
cp -f ${GLIDE_CONF_FN} ${GLIDE_BACKUP_DIR}
cp -f ${GLIDE_LOCK_FN} ${GLIDE_BACKUP_DIR}

### GOM #####################################################################################################

# ref(s):
#  -  https://github.com/mattn/gom
go get -v ${GOM_VCS_URI:-"github.com/mattn/gom"}
export GOM_VENDOR_NAME=${GOM_VENDOR_NAME:-"sniperkit"}
export GOM_GEN_BACKUP_STATUS=${GOM_GEN_BACKUP_STATUS:-"TRUE"}
export GOM_GEN_STATUS=${GOM_GEN_STATUS:-"TRUE"}
export GOM_GEN_TRAVIS_STATUS=${GOM_GEN_TRAVIS_STATUS:-"TRUE"}
export TRAVIS_CI_BACKUP_DIR=${TRAVIS_CI_BACKUP_DIR:-"/shared/conf.d/ci/travis"}
export TRAVIS_CI_FILENAME=${TRAVIS_CI_FILENAME:-".travis.yml"}

mkdir -p ${GOM_BACKUP_DIR}
if [ ! -f Gomfile ]; then
	gom gen gomfile
fi
cp -f Gomfile* ${GOM_BACKUP_DIR}

## gom gen travis
mkdir -p /shared/conf.d/ci/travis
mkdir -p /shared/logs/krakend
if [ ! -f ${TRAVIS_CI_FILENAME} ]; then
 	gom gen travis-yml
fi
## copy new travis file
if [ -f ${TRAVIS_CI_FILENAME} ]; then
	cp -fR *travis* ${TRAVIS_CI_BACKUP_DIR}
else
	echo "error occured whil creating travis file with gom utility (${BUILD_DATE})" >> /shared/logs/krakend/gom_gen_travis.log
fi

### GOX #######################################################################################################

# copy to /usr/local/sbin/ all generated binaries for alpine linux
gox -os="linux" -arch="amd64" -output="/usr/local/sbin/{{.Dir}}" $(glide novendor)

### DIST #######################################################################################################

## Copy to dist files [optional]
share_recent_dist_files

### CLEAN #######################################################################################################

# Cleanup GOPATH
rm -Rf ${GOPATH}

# Cleanup APK dependencies
apk del --no-cache --no-progress .go-deps
apk del --no-cache --no-progress .cgo-deps
apk del --no-cache --no-progress .go-tools-deps
apk del --no-cache --no-progress .go-cross-deps
