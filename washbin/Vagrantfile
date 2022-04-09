# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.network "private_network", ip: "10.1.2.10"
  config.vm.provision "shell", path: "provision/script.sh"
end
