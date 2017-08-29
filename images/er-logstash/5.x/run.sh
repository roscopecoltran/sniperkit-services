#!/bin/bash

# Run interactive
docker run -it --rm --net=host -v /home/centos/logstash/conf:/conf armdocker.rnd.ericsson.se/proj_kds/er/logstash logstash -f /conf --debug

# Normal run
#docker run -d --net='host' --restart=always -v /home/centos/logstash/conf:/conf -v /home/centos/logstash/log:/var/log/logstash --name=logstash armdocker.rnd.ericsson.se/proj_kds/er/logstash:5.1.1 logstash -f /conf -l /var/log/logstash/
