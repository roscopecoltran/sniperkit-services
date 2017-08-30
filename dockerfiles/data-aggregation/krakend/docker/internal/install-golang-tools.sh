#!/bin/sh
set -x
set -e

GOLANG_TOOLS_LIST=${GOLANG_TOOLS_LIST:-""}

# install and update tools
echo "Installing Gometalinter"
go get -u -f github.com/alecthomas/gometalinter
gometalinter --install --update --force

echo "Installing FixImports"
go get -u -f github.com/corsc/go-tools/fiximports/

echo "Installing Gonerator"
go get -u -f github.com/corsc/go-tools/gonerator/

echo "Installing PackageCoverage"
go get -u -f github.com/corsc/go-tools/package-coverage/

echo "Installing Refex"
go get -u -f github.com/corsc/go-tools/refex/