
.PHONY: all
all: runtime

.PHONY: clean
clean:
	docker rmi -f smizy/mosquitto:${TAG} || :

.PHONY: runtime
runtime:
	docker build \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg VCS_REF=${VCS_REF} \
		--build-arg VERSION=${VERSION} \
		-t smizy/mosquitto:${TAG} .
	docker images | grep mosquitto

.PHONY: test
test:
	bats test/test_*.bats
