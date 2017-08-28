#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
. ${DIR}/common.sh

## #################################################################
## global env variables
## #################################################################

# Set temp environment vars
export LIBGIT2REPO=https://github.com/libgit2/libgit2.git
export LIBGIT2BRANCH=${LIBGIT2BRANCH:-"v0.26.0"}
export LIBGIT2PATH=/tmp/libgit2

# Compile & Install libgit2 (v0.26)
git clone -b ${LIBGIT2BRANCH} --depth 1 -- ${LIBGIT2REPO} ${LIBGIT2PATH}

mkdir -p ${LIBGIT2PATH}/build
cd ${LIBGIT2PATH}/build
cmake .. -DBUILD_CLAR=off
cmake --build . --target install

# Cleanup
rm -r ${LIBGIT2PATH}

echo 
