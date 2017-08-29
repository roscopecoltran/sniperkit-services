
.PHONY: all
all: runtime

.PHONY: clean
clean:
	docker rmi -f smizy/opentsdb:${TAG} || :

.PHONY: runtime
runtime:
	docker build \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg VCS_REF=${VCS_REF} \
		--build-arg VERSION=${VERSION} \
		-t smizy/opentsdb:${TAG} .
	docker images | grep opentsdb

.PHONY: test
test:
	(docker network ls | grep vnet ) || docker network create vnet
	regionserver=1 tsdb=1 ./make_docker_compose_yml.sh hdfs hbase tsdb \
		| sed -E 's/(HADOOP|YARN)_HEAPSIZE=1000/\1_HEAPSIZE=300/g' \
		> docker-compose.ci.yml.tmp
	docker-compose -f docker-compose.ci.yml.tmp up -d 
	docker-compose ps
	docker run --net vnet --volumes-from tsdb-1 smizy/opentsdb:${VERSION}-alpine  bash -c 'for i in $$(seq 200); do nc -z tsdb-1.vnet 4242 && echo test starting && break; echo -n .; sleep 1; [ $$i -ge 200 ] && echo timeout && exit 124 ; done'
	
	bats test/test_*.bats

	docker-compose -f docker-compose.ci.yml.tmp stop
