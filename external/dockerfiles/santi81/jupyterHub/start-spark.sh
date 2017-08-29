#!/bin/bash


set -e

if [ "$#" != 1  ]; then
        echo Usage: $0 "gke or onPrem"
        exit 1
fi

deploy="$1"


# Use the spark-master-controller.yaml file to create a replication controller running the Spark Master service
kubectl --namespace=jupyterhub create -f spark/spark-master-controller.yaml

# create a logical service endpoint that Spark workers can use to access the Master pod:
kubectl --namespace=jupyterhub create -f spark/spark-master-service.yaml

# Deploy the proxy controller 
kubectl --namespace=jupyterhub create -f spark/spark-ui-proxy-controller.yaml

# Use the spark-worker-controller.yaml file to create a replication controller that manages the worker pods.
if [ "$deploy" == "onPrem" ]; then
	kubectl --namespace=jupyterhub create -f spark/spark-worker-controller.yaml
else
	kubectl --namespace=jupyterhub create -f spark/spark-worker-controller_gke.yaml
fi


# Use the spark-ui-proxy-service.yaml file to expose spark ui proxy service
if [ "$deploy" == "onPrem" ]; then 
	kubectl --namespace=jupyterhub create -f spark/spark-ui-proxy-service.yaml
else
	kubectl --namespace=jupyterhub create -f spark/spark-ui-proxy-service_gke.yaml
fi
 
