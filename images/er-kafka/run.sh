#!/bin/bash
 _host_ip=`echo $(hostname -I | head -n 1 | cut -d " " -f1)`
docker run -it --rm --net=host -e "KAFKA_EXT_IP=${_host_ip}" er/kafka sh