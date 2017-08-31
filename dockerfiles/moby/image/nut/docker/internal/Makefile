all: generate

fmt:
	go fmt ./...

install-deps:
	go get github.com/jteeuwen/go-bindata/...
	go get github.com/elazarl/go-bindata-assetfs/...

glide-install:
	glide install --force

logrus-fix:
	rm -fr vendor/github.com/Sirupsen
	find vendor -type f -exec sed -i 's/Sirupsen/sirupsen/g' {} +

generate: clean generate-models

generate-proto:
	protoc --gogofaster_out=. -Iproto -I$(GOPATH)/src proto/caffe2.proto

generate-models:
	go-bindata -nomemcopy -prefix builtin_models/ -pkg caffe2 -o builtin_models_static.go -ignore=.DS_Store  -ignore=README.md builtin_models/...

clean-models:
	rm -fr builtin_models_static.go

clean-proto:
	rm -fr *pb.go

clean: clean-models

travis: install-deps glide-install logrus-fix generate
	echo "building..."
	go build