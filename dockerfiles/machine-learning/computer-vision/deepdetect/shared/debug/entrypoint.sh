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

if [[ -d ./$1 ]]; then
	cd ./$1
else
	cd /shared/apps
fi

clear
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

  'dev-demos')
		apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM}
		apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD} ${APK_BUILD_CUSTOM}
		if [[ -d /app/appname/demos ]]; then
			ln -s /shared/apps /app/appname/demos
		fi
  	exec /bin/bash
	;;

  sniperkit_*)
		c=0
		for i in $(echo $1 | tr "_" " ")
		do
			if [ $c -eq 0 ]; then
				APP_SECTION_OWNER=$i
			fi
			if [ $c -eq 1 ]; then
				APP_SECTION_SLUG=$i
			fi
			c=$((c+1))
		done
		APP_SECTION_EXPECTED_DIR="/shared/apps/${APP_SECTION_SLUG}"
		if [[ -d ${APP_SECTION_EXPECTED_DIR} ]]; then
			cd ${APP_SECTION_EXPECTED_DIR}
			pwd
			ls -l 
			# requirements-dev.txt
			find . -name requirements*.txt -exec pip install --no-cache --no-cache-dir -r {} \;
			if [[ -f ${APP_SECTION_EXPECTED_DIR}/setup.py ]]; then	
				pip install --no-cache --no-cache-dir -e .
			else
				exec python -m $1
			fi
			if [[ -f ${APP_SECTION_EXPECTED_DIR}/Makefile ]]; then	
				exec make run
			else
				exec python -m $1
			fi
		fi
	;;

  'sniperkit-dev')
		apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM}
		apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD} ${APK_BUILD_CUSTOM}		
  	exec /bin/bash
	;;

  *)
  	exec appname $@ 
	;;

esac