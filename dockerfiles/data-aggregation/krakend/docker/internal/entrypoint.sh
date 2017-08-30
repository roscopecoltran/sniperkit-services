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
	cd /app
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

  launch_default_*)
		exec gin -d \
				 -p 8096 \
				 -c /shared/conf.d/default/${KRAKEND_BASENAME}.json \
				 -cors-origins http://127.0.0.1:8096,http://example.com,http://ssl.example.com,https://127.0.0.1:8096,https://example.com,https://ssl.example.com
	;;

  *)
  	exec $@
	;;

esac