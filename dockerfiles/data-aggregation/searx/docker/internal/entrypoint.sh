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

  'searx_standalone')
	python /app/searx/searx/utils/standalone_searx.py
	;;

  'searx_admin')
	python /app/searx-admin/admin/webapp.py
	;;

  'searx_self_signed')
		if [ ! -f /usr/local/searx/ssl/searx.key ]
		then
		    mkdir -p /shared/ssl
		    openssl req \
		       -subj "/C=${COUNRTY:-''}/ST=${STATE:-''}/L=${LOCALITY:-''}/O=${ORG:-''}/OU=${ORG_UNIT:=''}/CN=${COMMON_NAME:-''}" \
		       -newkey rsa:4096 -nodes -keyout /shared/ssl/searx.key \
		       -x509 -days 3650 -out /shared/ssl/searx.crt
		fi
		sed -i -e "s|base_url : False|base_url : ${BASE_URL}|g" \
		       -e "s/image_proxy : False/image_proxy : ${IMAGE_PROXY}/g" \
		       -e "s/ultrasecretkey/$(openssl rand -hex 16)/g" \
		       /usr/local/searx/searx/settings.yml
		supervisord -c /etc/supervisord.conf
	;;

	# https://github.com/adeweever91/searx_ss
  'supervisor')
	/usr/bin/supervisord
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

  	exec $@
	;;

esac