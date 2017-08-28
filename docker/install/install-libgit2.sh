#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
. ${DIR}/internal/common.sh
. ${DIR}/internal/env-aliases.sh
. ${DIR}/internal/vcs-git.sh

## #################################################################
## global env variables
## #################################################################

# Set temp environment vars
export LIBGIT2_VCS_REPO=https://github.com/LIBGIT2_VCS_/LIBGIT2_VCS_.git
export LIBGIT2_VCS_BRANCH=${LIBGIT2_VCS_BRANCH:-"v0.26.0"}
export LIBGIT2_VCS_PATH=/tmp/LIBGIT2_VCS_

# Compile & Install LIBGIT2_VCS_ (v0.26)
git clone -b ${LIBGIT2_VCS_BRANCH} --depth 1 -- ${LIBGIT2_VCS_REPO} ${LIBGIT2_VCS_PATH}

mkdir -p ${LIBGIT2_VCS_PATH}/build
cd ${LIBGIT2_VCS_PATH}/build
cmake .. -DBUILD_CLAR=off
cmake --build . --target install

# Cleanup
rm -r ${LIBGIT2_VCS_PATH}

echo 
