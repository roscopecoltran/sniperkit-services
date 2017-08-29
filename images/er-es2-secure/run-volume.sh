!/bin/bash
echo "do not forget to login to armdocker.rnd.ericsson.se/proj_kds/"

#docker run -d --restart=always --net=host -e HOST=20.20.20.88 -e ES_JAVA_OPTS="-Xms6g -Xmx6g" -v /opt/elasticsearch/data --name=es armdocker.rnd.ericsson.se/proj_kds/er/elasticsearch:5.1.1

check_volume="$(docker inspect -f {{.State.Status}} es-data-volume)"

#if [ $check_volume == 'created' ]; then
#  echo "ES data volume is already $check_volume. Nothing to do"
#else
#  echo "Creating ES data volume"
  # create volume data container
#  docker create -v /opt/elasticsearch/data --name es-data-volume armdocker.rnd.ericsson.se/proj_kds/er/kibana:5.1.1 /bin/true
#fi

# Volume mount -> access denied
#docker run -d --restart=always --net=host -e HOST=20.20.20.88 -e ES_JAVA_OPTS="-Xms6g -Xmx6g" --volumes-from es-data-volume --name=es-server armdocker.rnd.ericsson.se/proj_kds/er/elasticsearch:5.1.1

# local FS mount
docker run  -d --restart=always --net=host -e HOST=20.20.20.88 -e ES_JAVA_OPTS="-Xms6g -Xmx6g" -v /home/centos/data/es:/opt/elasticsearch/data --name=es-server armdocker.rnd.ericsson.se/proj_kds/er/elasticsearch:5.1.1

