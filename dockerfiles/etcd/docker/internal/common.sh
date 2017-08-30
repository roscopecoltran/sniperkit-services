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

# usage
# copy_recent_files 10
function share_recent_dist_files {
	APP_LOCAL_SBIN=${APP_LOCAL_SBIN:-"/usr/local/sbin/"}
	APP_SHARED_DIST=${APP_SHARED_DIST:-"/shared/dist"}
	APP_TIMESCOPE_AS_NEW_DIST=${APP_TIMESCOPE_AS_NEW_DIST:-"5"}
	mkdir -p ${APP_SHARED_DIST}
	find ${APP_LOCAL_SBIN} -ctime -${APP_TIMESCOPE_AS_NEW_DIST} -exec cp -Rf ${APP_SHARED_DIST}
}
