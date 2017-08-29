#!/bin/sh

sed -i -e "s/TDIARY_HOST/${TDIARY_HOST}/g" ${TDIARY_ROOT}/nginx-site.conf
nginx -c ${TDIARY_ROOT}/nginx.conf