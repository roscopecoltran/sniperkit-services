### Requirements ###
docker, docker-compose

### How to build docker image ###
```
$ docker build -t "package-name:latest"
```

### How to start the cluster ###
```
$ docker-compose up --force-recreate
```

For more docker images visit http://hub.docker.com

use build_images.sh to build all necessary images 

I Producer(KafkaProducer) used to simulate sending random generated json data which contains 4 fields( id , revenue , revenue_counter , timestamp)

II Spark procesing over kafka producer's data(saving incoming data from producer to redis(via spark) because some of the records may be updated )
	- from spark app is crated a new kafka producer which handles the computated data
	- how to run spark in standalone mode ( not distributed with Hadoop(hdfs)) :
			
			1.First create the datastore container so all the other container can use the datastore container's data volume with createDatastoreContainer.sh docker volumes can be checked with -> docker volume ls , after running the script for datastore type the command and the volume for the datastore should be the first one from top to bottom.

			2.Create spark master container with createSparkMasterContainer.sh script

			3.After second step with spark master then create spark slave container with createSparkSlaveContainer.sh script
			(can create as many workers as we want , link option allows the container automatically connect to the other (master in this case) by being added to the same network.)
				- spark workers can be scaled with the following command docker-compose scale slave = $1 ( whatever number do we need)

			4.Running a spark code using spark-submit
			Another container is created to work as the driver and call the spark cluster. The container only runs while the spark job is running, as soon as it finishes the container is deleted.
			The spark python code should be moved to the shared volume created by the datastore container. Since we did not specify a host volume (when we manually define where in the host machine the container is mapped) docker creates it in the default volume location located on /var/lib/volumes/<container hash>/_data

			5.Run the spark submit container
			docker run --rm -it --link master:master --volumes-from spark-datastore spark-submit:latest spark-submit --master spark://172.17.0.2:7077 /data/sparkContextExample.py
			Or the script spark_submit.sh can be used while passing a spark code .py file as argument

			* check the addres of spark master , last number can be different from 2 -> check on localhost:8080 where spark master runs

	*** sparkContextExample 
	There are two ways of creating spark stream with kafka
	- using KafkaUtils.createStream which takes data from the moment that producer started work.For example if the prodecer started work at 10:00am and the spark app is submited at 02:00pm 'createStream' will take all the data from 10:00 to 02:00pm and will keep working in real time until is stopped.
	- using KafkaUtils.createDirectStream whiche take data from the moment that the spark app is submited.

III Consumer(KafkaConsumer) used to receive data from the producer in spark app
