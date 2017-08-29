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

function touch_all {
	local TOUCH_DIR=${1:-"."}
	find ${TOUCH_DIR}/* -exec touch {} \;
	# or
	# find . | xargs touch
}

