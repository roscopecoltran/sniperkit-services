# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # --provider lxc
  config.vm.provider :lxc do |lxc, override|
    lxc.customize "network.ipv4", "10.0.3.101/24"

    override.vm.box = "dragosc/trusty64"
  end

  # --provider virtualbox
  config.vm.provider :virtualbox do |virtualbox, override|
    override.vm.network "private_network", ip: "192.168.50.101"

    # virtualbox.memory = 2048
    # virtualbox.cpus = 1

    # override.vm.box = "ubuntu/xenial64" # 16.04 - NOT LAUNCHED
    # override.vm.box = "ubuntu/wily64" # 15.10
    # override.vm.box = "ubuntu/vivid64" # 15.04
    override.vm.box = "ubuntu/trusty64" # 14.04
  end

  # # --provider libvirt
  # config.vm.provider :libvirt do |libvirt, override|
  #   raise Vagrant::Errors::VagrantError.new, "We didn't configure our Vagrantfile for the 'libvirt' provider"
  # end

  config.vm.provision "shell", inline: <<SHELL
    apt-get update
    apt-get install -y curl make wget
    curl -sSL https://get.docker.com/ | bash
    # curl -L "https://github.com/docker/compose/releases/download/$(docker --version | awk -F ' ' '{print $3}' | awk -F ',' '{print $1}')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    curl -L "https://github.com/docker/compose/releases/download/1.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod 755 /usr/local/bin/docker-compose
SHELL

end