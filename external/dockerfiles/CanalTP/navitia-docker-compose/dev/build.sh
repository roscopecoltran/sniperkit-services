#!/bin/bash

# we don't want python to use .pyc in the docker because it can mess stuff if the .pyc
# has been also generated in the host machine
export PYTHONDONTWRITEBYTECODE=1

#we want to be able to interupt the build, see: http://veithen.github.io/2014/11/16/sigterm-propagation.html
function run() {
    trap 'kill -TERM $PID' TERM INT
    $@ &
    PID=$!
    wait $PID
    trap - TERM INT
    wait $PID
    return $?
}
# for the tests we need rabbitmq
service rabbitmq-server start

navitia_dir=/work/navitia

build_dir=/work/build

cd $build_dir

# compilation preparation
run cmake -DCMAKE_BUILD_TYPE=Release $navitia_dir/source

# install python dependencies
run pip install -r $navitia_dir/source/jormungandr/requirements_dev.txt

# compilation
run make -j$(nproc)

# run the main tests
run make test

# run docker tests, for this you need to mount the docker sockettxt
run pip install -r $navitia_dir/source/tyr/requirements_dev.txt
run pip install -r $navitia_dir/source/eitri/requirements.txt
run make docker_test
