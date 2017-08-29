#!/bin/bash
 _host_ip=`echo $(hostname -I | head -n 1 | cut -d " " -f1)`
# Test
# docker run -it --rm --net=host -e "KAFKA_EXT_IP=${_host_ip}" -v /mnt/data/kafka/logs:/opt/kafka/logs -v /mnt/data/kafka/log:/opt/kafka/log er/kafka sh

# Ignore error
docker rm -f kafka || true
docker run -d --net=host --name="kafka" -e "KAFKA_EXT_IP=${_host_ip}" -v /mnt/data/kafka/logs:/opt/kafka/logs -v /mnt/data/kafka/log:/opt/kafka/log er/kafka
