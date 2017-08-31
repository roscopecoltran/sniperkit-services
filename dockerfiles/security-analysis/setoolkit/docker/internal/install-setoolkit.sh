#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
if [ -f ${DIR}/common.sh ]; then
	. ${DIR}/common.sh
fi

if [ -f ${DIR}/aliases.sh ]; then
	. ${DIR}/aliases.sh
fi

# refs:
#  - https://github.com/trustedsec/social-engineer-toolkit

# Set temp environment vars
export SETOOLKIT_VCS_URL=${SETOOLKIT_VCS_URL:-"https://github.com/trustedsec/social-engineer-toolkit.git"}
export SETOOLKIT_VCS_BRANCH=${SETOOLKIT_VCS_BRANCH:-"7.7.1"}
export SETOOLKIT_VCS_CLONE_DEPTH=${SETOOLKIT_VCS_CLONE_DEPTH:-"1"}
export SETOOLKIT_VCS_CLONE_PATH=${SETOOLKIT_VCS_CLONE_PATH:-"/app/setoolkit"}
export PATH=${SETOOLKIT_VCS_CLONE_PATH}:$PATH

if [[ -d ${SETOOLKIT_VCS_CLONE_PATH} ]]; then
	rm -fR ${SETOOLKIT_VCS_CLONE_PATH}
fi

# Clone, Compile & Install
git clone -b ${SETOOLKIT_VCS_BRANCH} --recursive --depth ${SETOOLKIT_VCS_CLONE_DEPTH} -- ${SETOOLKIT_VCS_URL} ${SETOOLKIT_VCS_CLONE_PATH}
cd ${SETOOLKIT_VCS_CLONE_PATH}

pip install --no-cache --no-cache-dir -r /shared/conf.d/pip/requirements.txt
python setup.py install


