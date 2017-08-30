
.PHONY: all
all: runtime

.PHONY: clean
clean:
	docker rmi -f smizy/word2vec:${TAG} || :

.PHONY: runtime
runtime:
	docker build \
		--build-arg BUILD_DATE=${BUILD_DATE} \
		--build-arg VCS_REF=${VCS_REF} \
		--build-arg VERSION=${VERSION} \
		-t smizy/word2vec:${TAG} .
	docker images | grep word2vec

.PHONY: test
test:
	bats test/test_*.bats

