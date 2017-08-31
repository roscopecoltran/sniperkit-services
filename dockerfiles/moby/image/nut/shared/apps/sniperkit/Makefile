.PHONY: all deps build

# This Makefile is a simple example that demonstrates usual steps to build a binary that can be run in the same
# architecture that was compiled in. The "ldflags" in the build assure that any needed dependency is included in the
# binary and no external dependencies are needed to run the service.

NUT_VERSION=$(shell git describe --always --long --dirty --tags)
BIN_NAME=nut${NUT_VERSION}-sniperkit

all: deps build

deps:

build:
	go build -a -ldflags="-X github.com/matthieudelaro/nut/core.NutVersion=${NUT_VERSION}" -o ${BIN_NAME}
	@echo "You can now use ./${BIN_NAME}"