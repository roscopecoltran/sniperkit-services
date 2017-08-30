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
export PROJECT_VCS_URI=${PROJECT_VCS_URI:-"github.com/beniz/deepdetect.git"}
export PROJECT_VCS_BRANCH=${PROJECT_VCS_BRANCH:-"master"}
export PROJECT_VCS_CLONE_DEPTH=${PROJECT_VCS_CLONE_DEPTH:-"1"}
export PROJECT_VCS_CLONE_PATH=${PROJECT_VCS_CLONE_PATH:-"/app/deepdetect"}

if [[ -d ${PROJECT_VCS_CLONE_PATH} ]]; then
	rm -fR ${PROJECT_VCS_CLONE_PATH}
fi

# Clone, Compile & Install
git clone -b ${PROJECT_VCS_BRANCH} --recursive --depth ${PROJECT_VCS_CLONE_DEPTH} -- https://${PROJECT_VCS_URI} ${PROJECT_VCS_CLONE_PATH}

mkdir -p ${PROJECT_VCS_CLONE_PATH}/build
cd ${PROJECT_VCS_CLONE_PATH}/build

cmake -DCMAKE_BUILD_TYPE=Release ..

# to finish

ls -l 
