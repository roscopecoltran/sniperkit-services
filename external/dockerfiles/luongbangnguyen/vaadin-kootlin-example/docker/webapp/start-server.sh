#!/bin/sh
while (! nc -z elasticsearch 9300) && (! nc -z mysql 3306); do
    echo "Waiting for upcoming Elasticsearch and Mysql"
    sleep 2
done
java -Djava.security.egd=file:/dev/./urandom -jar /opt/vaadin-example/lib/vaadin-example-web.jar