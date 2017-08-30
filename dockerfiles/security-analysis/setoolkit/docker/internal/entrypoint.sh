#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
. ${DIR}/common.sh

pwd

if [[ -d ./$1 ]]; then
	cd ./$1
else
	cd ${APP_HOME:-"/app/$APP_USER"}
fi

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

  'seautomate')
	exec seautomate 
	;;
	
  'seproxy')
	exec seproxy 
	;;

  'seupdate')
	exec seupdate 
	;;

  'run')
	exec $APP_EXEC_PATH_FILE
	;;

  *)
  	exec $APP_EXEC_PATH_FILE
	;;

esac