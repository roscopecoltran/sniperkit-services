#!/bin/sh
set -x
set -e

# CURRENT_STATUS: FAIL (alpine)
# /opt/faiss/utils.h:52:24: error: field 'rand_data' has incomplete type 'faiss::random_data'
# refs
# - https://github.com/facebookresearch/faiss/blob/master/Dockerfile

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
. ${DIR}/common.sh

## #################################################################
## global env variables
## #################################################################

export PKG_CONFIG_PATH="/usr/lib/pkgconfig/:/usr/local/lib/pkgconfig/"

## #################################################################
## BerkleyDB - set temp environment vars
## #################################################################

# github - clone
export VCS_REPO_URI=${VCS_REPO_URI:-"github.com/facebookresearch/faiss"}
export VCS_REPO_BRANCH=${VCS_REPO_BRANCH:-"master"}
export VCS_REPO_CLONE_DEPTH=${VCS_REPO_CLONE_DEPTH:-1}
export VCS_REPO_LOCAL_PATH=${VCS_REPO_LOCAL_PATH:-"/opt/faiss"}

# alpine - apk dependencies
export VCS_REPO_DEPS_APK=${VCS_REPO_DEPS_APK:-"swig py-numpy g++ gcc musl-dev pkgconfig openblas-dev boost-dev freetype-dev libpng-dev"}
# export BLASLDFLAGS=${BLASLDFLAGS:-"/usr/lib/libopenblas.so.0"}

# CMake - variables and build type
export VCS_REPO_CMAKE_JOBS=${VCS_REPO_CMAKE_JOBS:-4}
export VCS_REPO_CMAKE_BUILD_TYPE=${VCS_REPO_CMAKE_BUILD_TYPE:-"Release"}
export VCS_REPO_CMAKE_ARGS=${VCS_REPO_CMAKE_ARGS:-"-DBUILD_TUTORIAL=OFF -DBUILD_TEST=OFF -DBUILD_WITH_GPU=OFF -DWITH_MKL=OFF"}

## #################################################################
## Facebook FAISS - download required package dependecies
## #################################################################

apk add --no-cache --update --virtual .faiss-deps ${VCS_REPO_DEPS_APK}
# pip install --no-cache --no-cache-dir numpy six tornado matplotlib

## #################################################################
## Facebook FAISS - download and check
## #################################################################

ensure_dir ${VCS_REPO_LOCAL_PATH}
git clone -b ${VCS_REPO_BRANCH} --depth ${VCS_REPO_CLONE_DEPTH} -- https://${VCS_REPO_URI} ${VCS_REPO_LOCAL_PATH}

## #################################################################
## Facebook FAISS - install generated libs and execs
## #################################################################

mkdir -p ${VCS_REPO_LOCAL_PATH}/build
cd ${VCS_REPO_LOCAL_PATH}

mv ./example_makefiles/makefile.inc.Linux ./makefile.inc

cd ${VCS_REPO_LOCAL_PATH}/build

cmake -DCMAKE_BUILD_TYPE=${VCS_REPO_CMAKE_BUILD_TYPE} ${VCS_REPO_CMAKE_ARGS} .. 
# make tests/test_blas -j $(nproc)
make -j${VCS_REPO_CMAKE_JOBS}
make py

## #################################################################
## Facebook FAISS - cleanup
## #################################################################

rm -r ${VCS_REPO_LOCAL_PATH}
apk del --no-cache .faiss-deps

## #################################################################
## Facebook FAISS - remove build files from the container
## #################################################################

# ensure_dir ${DOCKER_BUILD_WORKSPACE}
# echo

