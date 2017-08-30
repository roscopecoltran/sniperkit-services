#!/bin/bash

SPARK_HOME="/opt/spark-1.6.2-bin-hadoop2.6"

echo Using SPARK_HOME=$SPARK_HOME

. "${SPARK_HOME}/sbin/spark-config.sh"

. "${SPARK_HOME}/bin/load-spark-env.sh"

if [ "$SPARK_MASTER_PORT" = "" ]; then
  SPARK_MASTER_PORT=7077
fi

if [ "$SPARK_MASTER_IP" = "" ]; then
  SPARK_MASTER_IP="0.0.0.0"
fi

if [ "$SPARK_MASTER_WEBUI_PORT" = "" ]; then
  SPARK_MASTER_WEBUI_PORT=8080
fi

if [ "$SPARK_WORKER_WEBUI_PORT" = "" ]; then
  SPARK_WORKER_WEBUI_PORT=8081
fi

if [ "$SPARK_UI_PORT" = "" ]; then
  SPARK_UI_PORT=4040
fi

if [ "$SPARK_WORKER_PORT" = "" ]; then
  SPARK_WORKER_PORT=8581
fi

if [ "$CORES" = "" ]; then
  CORES=1
fi

if [ "$MEM" = "" ]; then
  MEM=1g
fi

if [ "$SPARK_MASTER_HOSTNAME" = "" ]; then
  SPARK_MASTER_HOSTNAME=`hostname -f`
fi

if [ "$HDFS_HOSTNAME" != "" ]; then
 HADOOP_CONF_DIR="/opt/spark-1.6.2-bin-hadoop2.6/conf"
 sed "s/HOSTNAME_MASTER/$SPARK_MASTER_HOSTNAME/" /opt/spark-1.6.2-bin-hadoop2.6/conf/core-site.xml.template > /opt/spark-1.6.2-bin-hadoop2.6/conf/core-site.xml 
fi

sed "s/HOSTNAME_MASTER/$SPARK_MASTER_HOSTNAME/" /opt/spark-1.6.2-bin-hadoop2.6/conf/spark-defaults.conf.template > /opt/spark-1.6.2-bin-hadoop2.6/conf/spark-defaults.conf
sed "s/SPARK_UI_PORT/$SPARK_UI_PORT/" /opt/spark-1.6.2-bin-hadoop2.6/conf/spark-defaults.conf > /opt/spark-1.6.2-bin-hadoop2.6/conf/spark-defaults.conf

SPARK_MASTER_URL="spark://$SPARK_MASTER_HOSTNAME:$SPARK_MASTER_PORT"
echo "Using SPARK_MASTER_URL=$SPARK_MASTER_URL"

if [ "$MODE" = "" ]; then
MODE=$1
fi

if [ "$MODE" == "master" ]; then 
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" --ip $SPARK_MASTER_IP --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	jupyter notebook --ip=0.0.0.0 

elif [ "$MODE" == "worker" ]; then
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL -c $CORES -m $MEM
else
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" --ip $SPARK_MASTER_IP --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL	-c $CORES -m $MEM &
	jupyter notebook --ip=0.0.0.0 
fi
