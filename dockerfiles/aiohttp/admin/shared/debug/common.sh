#!/bin/sh
set -x
set -e

function ensure_dir {
	clear
	echo -e " "
	echo -e " **** ensure_dir $1 *** "
	if [ -d ${1} ]; then
		tree ${1}
		rm -fR ${1}
	fi
	mkdir -p ${1}
	echo -e " "
}

# usage: 
#  - for python2: fix_python_symlinks_env 2
#  - for python3: fix_python_symlinks_env 3
function fix_python_symlinks_env {
	PYTHON_VERSION_MAJOR=${1:-"2"}
	PYTHON_EXPECTED=${2:-"/usr/bin/python$PYTHON_VERSION_MAJOR"}
	PYPIP_EXPECTED=${3:-"/usr/bin/pip$PYTHON_VERSION_MAJOR"}
	PYTHON_SYMLINKED=${4:-"/usr/bin/python"}
	PYPIP_SYMLINKED=${5:-"/usr/bin/pip"}
	if [[ -f ${PYTHON_EXPECTED} ]]; then
		if [[ ! -f /usr/bin/python ]]; then
			ln -s ${PYTHON_EXPECTED} /usr/bin/python
		else
			local PYTHON_EXECUTABLE=$(which python)
			local PYTHON_VERSION=$(${PYTHON_EXECUTABLE} --version)
			SUCCESS_PY=" [ok] symlink already exists for 'python'. found: ${PYTHON_EXECUTABLE}"
		fi
	else
		ERROR_PY=" missing executable binary for 'python' - v${PYTHON_VERSION_MAJOR}.x). expected: ${PYTHON_EXPECTED}"
	fi
	if [[ -f ${PYPIP_EXPECTED} ]]; then
		if [[ ! -f ${PYPIP_SYMLINKED} ]]; then
			ln -s ${PYPIP_EXPECTED} ${PYPIP_SYMLINKED}
		else
			local PYPIP_EXECUTABLE=$(which pip)
			local PYPIP_VERSION=$(${PYPIP_EXECUTABLE} --version)
			SUCCESS_PYPIP=" [ok] symlink already exists for 'py-pip'. found: ${PYPIP_EXECUTABLE}"
		fi
	else
		ERROR_PYPIP=" missing executable binary for 'py-pip' - v${PYTHON_VERSION_MAJOR}.x). expected: ${PIP_EXPECTED}"
	fi
	PYTHON_RESULT="  symlink created: ${PYTHON_EXECUTABLE} (${PYTHON_VERSION}) --> ${PYTHON_SYMLINKED}"
	PYTPIP_RESULT="  symlink created: ${PYPIP_EXECUTABLE} (${PYPIP_VERSION}) --> ${PYPIP_SYMLINKED}"
}

fix_python_symlinks_env 3


