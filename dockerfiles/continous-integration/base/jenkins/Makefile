
#
# External Variables
#

PROJECT = jenkins
DOMAIN ?= qubestash
# DOMAIN = registry.gitlab.com/group # @see https://about.gitlab.com/2016/05/23/gitlab-container-registry/

#
# Build Variables
#

JENKINS_VERSIONS = 2.32.1 latest
DOCKER_BUILDER = docker build -t
# DOCKER_BUILDER = echo



all: build build-alpine

build:
	for TAG in $(JENKINS_VERSIONS); do \
		sed -e "s/jenkins:.*/jenkins:$$TAG/g" -i Dockerfile; \
		$(DOCKER_BUILDER) $(DOMAIN)/$(PROJECT):$$TAG .; \
	done
	docker images -a | grep $(DOMAIN)/$(PROJECT)

build-alpine: JENKINS_VERSIONS = alpine  2.32.1-alpine
build-alpine:
	for TAG in $(JENKINS_VERSIONS); do \
		sed -e "s/jenkins:.*/jenkins:$$TAG/g" -i Dockerfile; \
		$(DOCKER_BUILDER) $(DOMAIN)/$(PROJECT):$$TAG .; \
	done
	docker images -a | grep $(DOMAIN)/$(PROJECT)

clean: docker-rm docker-rm-images

# https://about.gitlab.com/2016/05/23/gitlab-container-registry/
deploy:
	docker push $(DOMAIN)/$(PROJECT)
	
docker-rm:
	docker rm -f $$(docker ps -a | grep $(DOMAIN)/$(PROJECT) | awk -F ' ' '{print $$1}') || true

docker-rm-images:
	docker rmi -f $$(docker images -a | grep $(DOMAIN)/$(PROJECT) | awk -F ' ' '{print $$3}') || true

test-before:

test-after: docker-rm

test: test-before test-jenkins test-after

test-jenkins:
	cd .travis && docker-compose up -d
	docker ps -a
	sleep 10
	docker ps -a | grep 8080 | grep -v Exited