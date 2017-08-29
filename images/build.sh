#!/bin/sh
cd java; docker build -t er/java-jdk8 .
cd ../logstash; docker build -t er/logstash2 .
