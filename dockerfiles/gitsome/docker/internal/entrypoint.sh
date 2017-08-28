#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
echo "$APP_HOME"

alias python=python3
alias pip=pip3

pwd
ls -l ${DIR}

if [[ -d ./$1 ]]; then
	cd ./$1
else
	cd ${APP_HOME}
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

  'conf-individual')
		gh configure
	;;

  'conf-entreprise')
		gh configure -e 
	;;

  'conf-feed')
		gh feed
	;;

  'my-feed')
		gh feed ${CONFIG_USER_LOGIN}
	;;
	# gh feed ${CONFIG_USER_LOGIN}
	# gh feed -p $@

  'my-notifications')
		gh notifications
	;;

  *)
  	exec gh $@
	;;

esac