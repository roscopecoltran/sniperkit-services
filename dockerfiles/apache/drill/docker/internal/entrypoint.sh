#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"

if [[ -f  ${DIR}/common.sh ]]; then
	. ${DIR}/common.sh
fi

function fix_python_symlinks_env {
	PYTHON_VERSION_MAJOR=${1:-"2"}
	PYTHON_EXPECTED=${2:-"/usr/bin/python$PYTHON_VERSION_MAJOR"}
	PIP_EXPECTED=${3:-"/usr/bin/pip$PIP_EXPECTED"}
	if [[ -f ${PYTHON_EXPECTED} ]]; then
		ln -s ${PYTHON_EXPECTED} /usr/bin/python
	else
		echo -e " missing executable binary (for python v${PYTHON_VERSION_MAJOR}.x). expected: ${PYTHON_EXPECTED}"
	fi
	if [[ -f ${PIP_EXPECTED} ]]; then
		ln -s ${PIP_EXPECTED} /usr/bin/pip
	else
		echo -e " missing executable binary (for py-pip v${PYTHON_VERSION_MAJOR}.x). expected: ${PIP_EXPECTED}"
	fi
}

fix_python_symlinks_env 3

function test_args {
	args_length=$(($#-1))
	args_array=${@:1:$length}
	args_shorter_array=${@:1:$#-1}
	args_shorter_array2="files = ${@:1:-1}, name = ${@: -1}"
	args_shorter_array3="${@:1:$(($#-1))}"
	echo $args_array
}

if [[ -d ./$1 ]]; then
	cd ./$1
else
	cd /shared/apps
fi

function multisite_switcher {
	WEBSITE_SLUG=${1:-"demos"}
	if [[ -d /shared/apps/$WEBSITE_SLUG ]]; then
		cd /shared/apps/$WEBSITE_SLUG
		if [[ -f /shared/apps/$WEBSITE_SLUG/Makefile ]]; then
			exec $@ make run
		fi
	fi
}

case "$1" in

  'interactive')
		apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM}
  	exec /bin/bash
	;;

  'bash')
		apk add --update --no-cache --no-progress bash
  	exec /bin/bash
	;;

  'dev')
		apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM}
		apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD} ${APK_BUILD_CUSTOM}
  	exec /bin/bash
	;;

  *)
  	exec $@ make run
	;;

esac