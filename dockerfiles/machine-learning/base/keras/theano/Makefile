
.PHONY: all
all: runtime

.PHONY: clean
clean:
	docker rmi -f smizy/keras-theano:${TAG} || :

.PHONY: runtime
runtime:
	docker build \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg VCS_REF=${VCS_REF} \
		--build-arg VERSION=${VERSION} \
		--rm -t smizy/keras-theano:${TAG} .
	docker images | grep keras-theano

.PHONY: test
test:
	docker run smizy/keras-theano:${TAG} python -c 'import keras'