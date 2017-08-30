#!/bin/bash

SPARK_HOME="/opt/spark-2.0.0-bin-hadoop2.7"

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

if [ "$CORES" = "" ]; then
  CORES=1
fi

if [ "$MEM" = "" ]; then
  MEM=1g
fi

if [ "$SPARK_MASTER_HOSTNAME" = "" ]; then
  SPARK_MASTER_HOSTNAME=`hostname -f`
fi


sed "s/HOSTNAME_MASTER/$SPARK_MASTER_HOSTNAME/" /opt/spark-2.0.0-bin-hadoop2.7/conf/spark-defaults.conf.template > /opt/spark-2.0.0-bin-hadoop2.7/conf/spark-defaults.conf

SPARK_MASTER_URL="spark://$SPARK_MASTER_HOSTNAME:$SPARK_MASTER_PORT"
echo "Using SPARK_MASTER_URL=$SPARK_MASTER_URL"

git config --global user.name  $GIT_USER && \
git config --global user.email $GIT_EMAIL

if [ "$MODE" = "" ]; then
MODE=$1
fi

if [ "$MODE" == "master" ]; then 
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" --ip $SPARK_MASTER_IP --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	jupyter notebook --ip=0.0.0.0 
	#--NotebookApp.server_extensions="['github_commit_push']"

elif [ "$MODE" == "worker" ]; then
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL -c $CORES -m $MEM
else
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.master.Master" --ip $SPARK_MASTER_IP --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT &
	${SPARK_HOME}/bin/spark-class "org.apache.spark.deploy.worker.Worker" --webui-port $SPARK_WORKER_WEBUI_PORT --port $SPARK_WORKER_PORT $SPARK_MASTER_URL	-c $CORES -m $MEM &
	jupyter notebook --ip=0.0.0.0 
	#--NotebookApp.server_extensions="['github_commit_push']"
fi
