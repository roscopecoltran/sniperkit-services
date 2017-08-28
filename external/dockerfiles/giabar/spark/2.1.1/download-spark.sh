#!/bin/bash
mirror=$(curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred')
url="${mirror}spark/spark-${SPARK_VER}/spark-${SPARK_VER}-bin-hadoop$HADOOP_VER.tgz"
wget "${url}" -O "/tmp/spark-$SPARK_VER-bin-hadoop$HADOOP_VER.tgz"
