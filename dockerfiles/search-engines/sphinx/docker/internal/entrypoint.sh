#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
cd /scripts
if [ -f ${DIR}/common.sh ]; then
	. ${DIR}/common.sh
fi

if [ -f ${DIR}/aliases.sh ]; then
	. ${DIR}/aliases.sh
fi

pwd

if [[ -d ./$1 ]]; then
	cd ./$1
else
	cd /app/searx
	pwd
	ls -l
fi

# PYTHON_VERSION=$(which python)
# PIP_VERSION=$(which pip)
alias python=python3
alias pip=pip3

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
	pip install -r /app/searx/requirements-dev.txt
  	exec /bin/bash
	;;

  'search')
	exec searchd --nodetach "${@:2}"
	;;

  'indexer')
	exec indexer --all --rotate "${@:2}"
	;;

  'bootsrap')
	exec indexer --all "$@" && searchd && while true; do indexer --all --rotate "$@"; sleep 5; done
	;;

  *)
	echo "=====> sleep 5"
	sleep 5

	echo "=====> indexer --rotate --all"
	indexer --all --rotate "$@"

	echo "=====> searchd"
	exec searchd --nodetach "$@"
  	# exec searchd --nodetach $@
	;;

esac