#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
. ${DIR}/common.sh
. ${DIR}/aliases.sh

# refs:
#  - https://github.com/sqlmapproject/sqlmap

# Set temp environment vars
export SQLMAP_VCS_URL=${SQLMAP_VCS_URL:-"https://github.com/sqlmapproject/sqlmap.git"}
export SQLMAP_VCS_BRANCH=${SQLMAP_VCS_BRANCH:-"1.1.8"}
export SQLMAP_VCS_CLONE_DEPTH=${SQLMAP_VCS_CLONE_DEPTH:-"1"}
export SQLMAP_VCS_CLONE_PATH=${SQLMAP_VCS_CLONE_PATH:-"/app/sqlmap"}
export PATH=${SQLMAP_VCS_CLONE_PATH}:$PATH

if [[ -d ${SQLMAP_VCS_CLONE_PATH} ]]; then
	rm -fR ${SQLMAP_VCS_CLONE_PATH}
fi

# Clone, Compile & Install
git clone -b ${SQLMAP_VCS_BRANCH} --recursive --depth ${SQLMAP_VCS_CLONE_DEPTH} -- ${SQLMAP_VCS_URL} ${SQLMAP_VCS_CLONE_PATH}
cd ${SQLMAP_VCS_CLONE_PATH}

python sqlmap.py -h
# python ${SQLMAP_VCS_CLONE_PATH}/sqlmap.py -h

