#*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"

  # mount shared folder
  config.vm.synced_folder ".", "/opt";
  
  config.vm.network "private_network",ip:"10.10.10.11"

  config.vm.provision "shell",path: "bootstrap.sh"
  
end
