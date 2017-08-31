#!/bin/sh
set -x
set -e

clear
echo

### DEFINITIONS ################################################################################################

export FN_MAKEFILE=${FN_MAKEFILE:-"Makefile"}
export FN_GOLANG_GLIDE=${FN_GOLANG_GLIDE:-"glide.yaml"}
export FN_GOLANG_GOM=${FN_GOLANG_GOM:-"Gomfile"}
export FN_GOLANG_GOPKG=${FN_GOLANG_GOPKG:-"Gopkg.toml"}

### ACTIONS ####################################################################################################

## golang
export USE_GOLANG_GET=${USE_GOLANG_GET:-"FALSE"}
export USE_GOLANG_TOOLS_FROM_SRC=${USE_GOLANG_TOOLS_FROM_SRC:-"FALSE"}
export IS_GOLANG_XBUILD=${IS_GOLANG_XBUILD:-"FALSE"}
export IS_GOLANG_CLEAN=${IS_GOLANG_CLEAN:-"TRUE"}

### gox
export USE_GOLANG_GOX=${USE_GOLANG_GOX:-"TRUE"}

### glide
export USE_GOLANG_GLIDE=${USE_GOLANG_GLIDE:-"TRUE"}
export USE_GOLANG_GLIDE_INSTALL=${USE_GOLANG_GLIDE_INSTALL:-"TRUE"}

### gom
export USE_GOLANG_GOM=${USE_GOLANG_GOM:-"FALSE"}

### gopkg
export USE_GOLANG_GOPKG=${USE_GOLANG_GOPKG:-"FALSE"}

### MAKFILE ####################################################################################################
# note: prefered way to build targets

export USE_GOLANG_MAKEFILE=${USE_GOLANG_MAKEFILE:-"FALSE"}
export USE_GOLANG_MAKEFILE_TARGETS=${USE_GOLANG_MAKEFILE_TARGETS:-"deps"} # trigger the targets (separated by spaces)

### GOLANG ####################################################################################################

export GOPATH=/go
export PATH=${PATH}:${GOPATH}/bin
export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

### PROJECT ####################################################################################################

export NUT_VCS_URI=${NUT_VCS_URI:-"github.com/matthieudelaro/nut"}
export NUT_VCS_BRANCH=${NUT_VCS_BRANCH:-"master"}
export NUT_VCS_DEPTH=${NUT_VCS_DEPTH:-"1"}

export NUT_VCS_CLONE_PATH=${GOPATH}/src/${NUT_VCS_URI}
export NUT_BUILD_DATE=${NUT_BUILD_DATE:-"$BUILD_DATE"}

### PRE_CHECK #################################################################################################

if [ "${NUT_VCS_URI}" == '' ]; then
	exit 1
fi

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
export APK_BUILD_GOLANG_TOOLS=${APK_BUILD_GOLANG_TOOLS:-""} # go-tools
export APK_BUILD_GOLANG_CROSS=${APK_BUILD_GOLANG_CROSS:-""} # go-cross-windows go-cross-freebsd go-cross-openbsd go-cross-darwin

### APK #######################################################################################################

apk add --no-cache --no-progress --update --virtual .go-deps ${APK_BUILD_GOLANG}
apk add --no-cache --no-progress --update --virtual .cgo-deps ${APK_BUILD_GOLANG_CGO}
apk add --no-cache --no-progress --update --virtual .go-tools-deps ${APK_BUILD_GOLANG_TOOLS}
apk add --no-cache --no-progress --update --virtual .go-cross-deps ${APK_BUILD_GOLANG_CROSS}

### VCS #######################################################################################################

# Compile & Install libgit2 (v0.23)
git clone -b ${NUT_VCS_BRANCH} --depth ${NUT_VCS_DEPTH} -- https://${NUT_VCS_URI} ${NUT_VCS_CLONE_PATH}
cd ${NUT_VCS_CLONE_PATH}
pwd
ls -l 
export NUT_VCS_VERSION=$(git ${BUILD_VCS_VERSION_ARGS:-"describe --always --long --dirty --tags"})

### SCRIPTS #######################################################################################################

if [ "$USE_GOLANG_TOOLS_FROM_SRC" == "TRUE" ]; then
	./install-golang-tools.sh
fi

### GOX #######################################################################################################

if [ "$USE_GOLANG_GOX" == "TRUE" ]; then
	go get -v ${GOX_VCS_URI:-"github.com/mitchellh/gox"}
fi

### TRAVIS_CI #################################################################################################

export TRAVIS_CI_BACKUP_DIR=${TRAVIS_CI_BACKUP_DIR:-"/shared/conf.d/ci/travis"}
export TRAVIS_CI_FILENAME=${TRAVIS_CI_FILENAME:-".travis.yml"}
mkdir -p ${TRAVIS_CI_BACKUP_DIR}

### GOM #######################################################################################################

# fin dall main.go files or all files with func main ?!
if [ "$USE_GOLANG_GOM" == "TRUE" ]; then
	if [ -f main.go ]; then

		# ref(s):
		#  -  https://github.com/mattn/gom
		go get -v ${GOM_VCS_URI:-"github.com/mattn/gom"}
		export GOM_VENDOR_NAME=${GOM_VENDOR_NAME:-"sniperkit"}
		export GOM_GEN_BACKUP_STATUS=${GOM_GEN_BACKUP_STATUS:-"TRUE"}
		export GOM_GEN_STATUS=${GOM_GEN_STATUS:-"TRUE"}
		export GOM_GEN_TRAVIS_STATUS=${GOM_GEN_TRAVIS_STATUS:-"TRUE"}
		export GOM_BACKUP_DIR=${GOM_BACKUP_DIR:-"/shared/conf.d/deps/gom"}

		mkdir -p ${GOM_BACKUP_DIR}
		if [ ! -f Gomfile ]; then
			gom gen gomfile
		fi
		cp -f Gomfile* ${GOM_BACKUP_DIR}

		## gom gen travis
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

	fi
fi

### MAKEFILE ###################################################################################################

if [ "$USE_GOLANG_MAKEFILE" == "TRUE" ]; then
	if [ -f ${USE_GOLANG_MAKEFILE_FN} ]; then
		for target in $USE_GOLANG_MAKEFILE_TARGETS; do	
			make ${target}
		done
	fi
fi

### GOPKG #######################################################################################################
# if [ "USE_GOLANG_GOPKG" == "TRUE" ]; then
# pattern_files: Gopkg.toml, Gopkg.lock
# fi

### GLIDE ######################################################################################################

if [ "$USE_GOLANG_GLIDE" == "TRUE" ]; then
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

	if [ ! -f ${GLIDE_CONF_FN} ]; then
		yes no | glide create
		cat glide.yaml 
	fi

	# logrus-fix
	# glide-install
	if [ "${USE_GOLANG_GLIDE_INSTALL}" == "TRUE" ]; then
		if [ -f ${GLIDE_CONF_FN} ]; then
			glide install --force --strip-vendor
		fi 
	fi

	# ref.
	#  - https://github.com/rai-project/plini/blob/master/.travis.yml#L17-L21
	#  - https://github.com/rai-project/caffe2/blob/master/Makefile#L10-L15
	if [ -d vendor/github.com/Sirupsen ]; then	
		rm -fr vendor/github.com/Sirupsen 
		# find . -name glide.yaml -exec sed -i 's/Sirupsen/sirupsen/g' {} +
		find ${GOPATH} -type f -exec sed -i 's/Sirupsen/sirupsen/g' {} +
		find . -type f -exec sed -i 's/Sirupsen/sirupsen/g' {} +
		if [ -f ${GLIDE_CONF_FN} ]; then
			cat glide.yaml
		fi
	fi

fi

### GO_GET ######################################################################################################
if [ "$USE_GOLANG_GET" == "TRUE" ]; then
	go get -v $(glide novendor)
fi

### BACKUP ######################################################################################################

##### GLIDE
if [ "$USE_GOLANG_GLIDE" == "TRUE" ]; then
	mkdir -p ${GLIDE_BACKUP_DIR}
	if [ -f ${GLIDE_CONF_FN} ]; then
		cp -f ${GLIDE_CONF_FN} ${GLIDE_BACKUP_DIR}
	fi
	if [ -f ${GLIDE_LOCK_FN} ]; then
		cp -f ${GLIDE_LOCK_FN} ${GLIDE_BACKUP_DIR}
	fi
fi

### EXECUTABLES_DIR ############################################################################################

export GOLANG_BUILD_BIN_SRC_DIR=${GOLANG_BUILD_BIN_SRC_DIR:-"\$(glide novendor)"}

### GOX ########################################################################################################

if [ "$USE_GOLANG_GOX" == "TRUE" ]; then
	if [ "IS_GOLANG_XBUILD" == "TRUE" ]; then
		gox -verbose -os="linux darwin windows" -arch="amd64" -output="/shared/dist/{{.Dir}}/{{.Dir}}_{{.OS}}_{{.ARCH}}" $(glide novendor)
	else
		gox -verbose -os="linux" -arch="amd64" -output="/usr/local/sbin/{{.Dir}}" $(glide novendor)
	fi
else
	go build $(glide novendor)
fi

### DIST #######################################################################################################

if [ "$IS_GOLANG_XBUILD" == "TRUE" ]; then
	## Copy to dist files [optional]
	share_recent_dist_files
fi

### CLEAN #######################################################################################################

if [ "$IS_GOLANG_CLEAN" == "TRUE" ]; then
	# Cleanup GOPATH
	rm -Rf ${GOPATH}
fi

# Cleanup APK dependencies
apk del --no-cache --no-progress .go-deps
apk del --no-cache --no-progress .cgo-deps
apk del --no-cache --no-progress .go-tools-deps
apk del --no-cache --no-progress .go-cross-deps
