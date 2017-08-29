# coreos docker

## init

    ssh core@yourserverip
    cd /home/core
    git clone https://github.com/ivories/docker.git
    chmod -R 777 docker/shell
    /home/core/docker/shell/shell_init
    export PATH="/home/core/docker/shell:$PATH"
    install
    install_web

## ssh-init

    ssh_config www.youname.com 

## set timezone

    sudo timedatectl set-timezone Asia/Shanghai

## set hostname

    sudo hostnamectl set-hostname yourname

## start/restart web service

    web

## install other service

    s bind                          # install bind server
    s samba                         # install samba share
    s git                           # install git server

## config the server

    cd /home/core/data/nginx
    vi nginx.conf # config nginx domain

    cd /home/core/data/php
    vi php.ini # config php.ini

    cd /home/core/data/mysql
    vi my.cnf # config my.cnf

## command list

    s service_name                  #start/restart fleetctl service
    p service_name                  #stop fleetctl service
    ss service_name                 #start/restart systemctl service
    st service_name                 #status systemctl service
    sp service_name                 #stop systemctl service
    fl                              #list all service
    fl service_name                 #list one fleetctl service(except global service)
    web                             #start/restart fleetctl web service
