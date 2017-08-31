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

# Set temp environment vars
export SEARX_VCS_URI=${SEARX_VCS_URI:-"github.com/asciimoo/searx.git"}
export SEARX_VCS_BRANCH=${SEARX_VCS_BRANCH:-"master"}
export SEARX_VCS_CLONE_DEPTH=${SEARX_VCS_CLONE_DEPTH:-"1"}
export SEARX_VCS_CLONE_PATH=${SEARX_VCS_CLONE_PATH:-"/app/searx"}

pip install --upgrade pip

if [[ -d ${SEARX_VCS_CLONE_PATH} ]]; then
	rm -fR ${SEARX_VCS_CLONE_PATH}
fi

# Clone, Compile & Install
git clone -b ${SEARX_VCS_BRANCH} --recursive --depth ${SEARX_VCS_CLONE_DEPTH} -- https://${SEARX_VCS_URI} ${SEARX_VCS_CLONE_PATH}
cd ${SEARX_VCS_CLONE_PATH}

pwd
pip install --no-cache --no-cache-dir -r ${SEARX_VCS_CLONE_PATH}/requirements.txt
pwd
pip install --no-cache --no-cache-dir -r ${SEARX_VCS_CLONE_PATH}/requirements-dev.txt
pwd
pip install --no-cache --no-cache-dir -e .

if [[ -f /app/searx/searx/settings.yml ]]; then
	mv /app/searx/searx/settings.yml /app/searx/searx/settings-github.yml
fi

ln -s /shared/conf.d/settings-default.yml /app/searx/searx/settings.yml

ls -l /app/searx/searx/*.yml

rm /etc/supervisord.conf
mkdir -p /shared/uwsgi/
ln -s /shared/conf.d/uwsgi/searx.ini /etc/uwsgi/


ln -s /shared/conf.d/supervisor/supervisord.conf /etc/

rm -f /etc/nginx/conf.d/default.conf
# cp /shared/conf.d/nginx/default.conf /etc/nginx/conf.d/
ln -s /shared/conf.d/nginx/default.conf /etc/nginx/conf.d/
