#!/bin/sh
set -x
set -e

pwd

if [[ -d ./$1 ]]; then
	cd ./$1
fi

# refs. 
#  - 

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

  'node')
	node --version
  	exec node 
	;;

  'yarn')
	yarn --version
  	exec yarn 
	;;

  'yarn-install')
	yarn --version
  	exec yarn install
	;;

  'npm')
	npm --version
  	exec npm 
	;;

  'npm-install')
	npm --version
  	exec npm install
	;;

  *)
  	exec /bin.bash
	;;

esac