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

# fix_python_symlinks_env 3

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
		if [[ -d /app/aiohttp_admin/demos ]]; then
			ln -s /shared/apps /app/aiohttp_admin/demos
		fi
  	exec /bin/bash
	;;

  aiohttpdemo_*)
		c=0
		for i in $(echo $1 | tr "_" " ")
		# for i in $(echo $1 | tr "_" "\n")
		do
			if [ $c -eq 0 ]; then
				DEMO_OWNER=$i
			fi
			if [ $c -eq 1 ]; then
				DEMO_SLUG=$i
			fi
			c=$((c+1))
		done
		DEMO_EXPECTED_DIR="/app/aiohttp_admin/demos/${DEMO_SLUG}"
		if [[ -d ${DEMO_EXPECTED_DIR} ]]; then
			cd ${DEMO_EXPECTED_DIR}
			pwd
			ls -l 
			# requirements-dev.txt
			find . -name requirements*.txt -exec pip install --no-cache --no-cache-dir -r {} \;
			if [[ -f ${DEMO_EXPECTED_DIR}/setup.py ]]; then	
				pip install --no-cache --no-cache-dir -e .
			else
				exec python -m $1
			fi
			if [[ -f ${DEMO_EXPECTED_DIR}/Makefile ]]; then	
				echo "luc"		
				exec make run
			else
				exec python -m $1
			fi
		fi
	;;

  'sniperkit')
		#apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM}
		#apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD} ${APK_BUILD_CUSTOM}
		# ln -s /shared/apps /app/aiohttp_admin/demos
		if [[ -d /app/aiohttp_admin/demos ]]; then
			ln -s /shared/apps /app/aiohttp_admin/demos
		fi
		cd /shared/apps/sniperkit
		make run
  	exec /bin/bash
	;;

  'dev-sniperkit')
		apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM}
		apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD} ${APK_BUILD_CUSTOM}		
  	exec /bin/bash
	;;

  *)
  	exec $@ make run 
	;;

esac