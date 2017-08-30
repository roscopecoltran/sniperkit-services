#! /bin/sh
set -e 

mkdir -p /var/lib/varnish/`hostname` && chown nobody /var/lib/varnish/`hostname`

if [ "x$VCL_USE_CONFIG" = "xno" ]; then
    varnishd -s malloc,${VCL_CACHE_SIZE} -a 0.0.0.0:80 -b ${VCL_BACKEND_ADDRESS}:${VCL_BACKEND_PORT}
else
    varnishd -s malloc,${VCL_CACHE_SIZE} -a 0.0.0.0:80 -F -f ${VCL_CONFIG}
fi

sleep 1
varnishlog