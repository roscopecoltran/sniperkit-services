#!/bin/bash

cd consumer
docker build -t consumer_test:latest .

cd ../producer
docker build -t producer_test:latest .

# cd ../mongodb
# docker build -t mongodb .

# cd ../docker_spark_test
# docker build -t spark_word_count .

cd ../spark
docker build -t spark_test:latest .

cd ..
