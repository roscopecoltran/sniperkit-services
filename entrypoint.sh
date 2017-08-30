#!/bin/bash


#SPARK_HOME=`realpath /opt/spark/spark-*/`
#SPARK_HOME=`readlink -f /opt/spark*/`
SPARK_HOME="/opt/spark-1.6.0-bin-hadoop2.6"

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

if [ "$SPARK_WORKER_PORT" = "" ]; then
  SPARK_WORKER_PORT=8581
fi

if [ "$SPARK_MASTER_HOSTNAME" = "" ]; then
  SPARK_MASTER_HOSTNAME=`hostname -f`
fi

SPARK_MASTER_URL="spark://$SPARK_MASTER_HOSTNAME:$SPARK_MASTER_PORT"
echo "Using SPARK_MASTER_URL=$SPARK_MASTER_URL"

if [ "$MODE" = "" ]; then
MODE=$1
fi

if [ "$MODE" == "headnode" ]; then 

	jupyter notebook --ip=0.0.0.0  &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" --ip $SPARK_MASTER_IP --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT

elif [ "$MODE" == "datanode" ]; then
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL
else
	jupyter notebook --ip=0.0.0.0  &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" --ip $SPARK_MASTER_IP --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL	
fi