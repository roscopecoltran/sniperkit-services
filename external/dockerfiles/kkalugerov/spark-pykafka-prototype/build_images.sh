#!/bin/bash 

cd producer
docker build -t producer_test:latest .

cd ../consumer
docker build -t consumer_test:latest .

cd ../spark-drive
docker build -t spark-drive:latest .

cd ../spark-master
docker build -t spark-master:latest .

cd ../spark-slave
docker build -t spark-slave:latest .

cd ../spark-submit
docker build -t spark-submit:latest .

