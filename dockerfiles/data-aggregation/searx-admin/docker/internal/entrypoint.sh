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

  'run')
	exec python /app/searx-admin/admin/webapp.py
	;;

  'tini-run')
	exec /sbin/tini -- /app/searx-admin/admin/webapp.py
	;;

  *)
		$@
	;;

esac