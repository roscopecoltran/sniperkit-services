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

function check_generated_output {
	pwd
	ls -l 
}

#
# refs:
#  - https://stackoverflow.com/questions/1562102/bash-find-and-copy 
#
# usage(s):
#  - find_and_copy_target "currencies.json" "/shared/data/searx" "find"
function find_and_copy_target {
	# find . -ctime -15 -exec cp {} ../otherfolder/ \;
	# find . -ctime 15 -print0 | xargs -0 cp --target-directory=../otherfolder
	# find . -ctime 15 -print0 | xargs -0 -I{} cp {} ../otherfolder
	local TARGET_PATTERN_BASENAME=${1:-""}
	local TARGET_PATTERN_SRC_DIR=${2:-"/app"}
	local TARGET_PATTERN_DEST_DIR=${3:-"/shared/data/searx/find"}
	local TARGET_PATTERN_PREFIX_PATH=${4:-"found"}
	local TARGET_PATTERN_FULL_DEST_DIR=${TARGET_PATTERN_DEST_DIR}/${TARGET_PATTERN_PREFIX_PATH}
	if [[ ! -d ${TARGET_PATTERN_DEST_DIR} ]]; then
		mkdir -p ${TARGET_PATTERN_DEST_DIR}
	fi
	find ${TARGET_PATTERN_SRC_DIR} -name ${TARGET_PATTERN_BASENAME} -exec cp {} /shared/data/searx/ \;

}

#
# usage(s):
#  - clean_py_cache "/app/searx" "*.pyc,__pycache__*" "recursive"
#  - clean_py_cache "/app/searx" "recursive"
function clean_py_cache {
	local TARGET_PATTERN_SRC_DIR=${1:-"/app"}
	local TARGET_PATTERN_BASENAME=${2:-""}
	local TARGET_PATTERN_RM_BEHAVIOUR=${3:-"recursive"}
	local TARGET_PATTERN_RM_APPENDED_OPTS=""
	if [[ ! -d ${TARGET_PATTERN_RM_BEHAVIOUR} ]]; then
		local TARGET_PATTERN_RM_APPENDED_OPTS+="R"
	fi
	find ${TARGET_PATTERN_SRC_DIR} -name "*.pyc" -exec rm -f${TARGET_PATTERN_RM_APPENDED_OPTS} {} \;
	find ${TARGET_PATTERN_SRC_DIR} -name "__pycache__*" -exec rm -f${TARGET_PATTERN_RM_APPENDED_OPTS} {} \;
    find ${TARGET_PATTERN_SRC_DIR} -type f -name "*.py[co]" -exec rm -f${TARGET_PATTERN_RM_APPENDED_OPTS} {} \;
    find ${TARGET_PATTERN_SRC_DIR} -type d -path '*/__pycache__/*' -exec rm -f${TARGET_PATTERN_RM_APPENDED_OPTS} {} \;
    find ${TARGET_PATTERN_SRC_DIR} -type d -name "__pycache__" -exec rm -f${TARGET_PATTERN_RM_APPENDED_OPTS} {} \;
}

#