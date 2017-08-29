#!/bin/bash 
_host_ip=`echo $(hostname -I | head -n 1 | cut -d " " -f1)`

# Test
# docker run -it --net=host -e ZK_SERVER_1=${_host_ip} armdocker.rnd.ericsson.se/proj_kds/er/zookeeper:3.4.9

# Daemon
docker run -d --restart=always --net=host -e ZK_SERVER_1=${_host_ip} -v /home/centos/zk/data:/opt/zookeeper/data --name=zookeeper armdocker.rnd.ericsson.se/proj_kds/er/zookeeper:3.4.9
