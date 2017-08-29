#!/bin/bash
# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

docker_repo=/etc/yum.repos.d/docker.repo
if [ ! -f $docker_repo ]; then
   echo "Adding $docker_repo."
   tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

fi

# install
yum install -y docker-engine
docker_path=/etc/systemd/system/docker.service.d
docker_conf=$docker_path/docker.conf
if [ ! -f $docker_conf ]; then
  # Create
  mkdir -p $docker_path

  # Add the docker conf file
  #TODO
fi  

# start
systemctl enable docker
systemctl start docker
