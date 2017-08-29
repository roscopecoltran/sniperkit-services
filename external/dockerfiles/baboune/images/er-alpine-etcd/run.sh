#!/bin/bash

mkdir -p /tmp/etcd
docker run -it --rm -v /tmp/etcd:/opt/etcd/data armdocker.rnd.ericsson.se/proj_kds/er/alpine-etcd:v3.1.5