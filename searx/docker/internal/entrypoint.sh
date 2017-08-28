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
	cd /app/searx
	pwd
	ls -l
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
	pip install -r /app/searx/requirements-dev.txt
  	exec /bin/bash
	;;

  'fetch_currencies')
	python /app/searx/searx/utils/fetch_currencies.py
	find_and_copy_target "currencies.json" "/shared/data/searx" "find"
	;;

  'fetch_languages')
	python /app/searx/searx/utils/fetch_languages.py
	find_and_copy_target "engines_languages.json" "/shared/data/searx" "find"
	;;

  'google_search')
	python /app/searx/searx/utils/google_search.py	
	;;

  'standalone_searx')
	python /app/searx/searx/utils/standalone_searx.py
	;;

  'update-translations')
	cd /app/searx/searx/utils
	./update-translations.sh
	find_and_copy_target "*.po" "/app/searx/searx/translations" "/shared/data/searx" "translations"
	;;

  'run')
	exec python /app/searx/searx/webapp.py
	;;

  'tini-run')
	exec /sbin/tini -- /app/searx/searx/webapp.py
	;;

  *)

  	exec /sbin/tini -- /app/searx/searx/webapp.py
	;;

esac