# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.define "ep_vm" do |ep_vm|

    ep_vm.vm.box = "centos/8"
    ep_vm.vbguest.installer_options = { allow_kernel_upgrade: true }
    
    ep_vm.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      
      # Display the VirtualBox GUI when booting the machine
      # vb.gui = true
    end

    # Provisioning
    ep_vm.vm.provision "file", source: ".bash_aliases", destination: "~/.bash_aliases"
    ep_vm.vm.provision "shell", path: "scripts/install.sh"

    ep_vm.vm.post_up_message = "Hello! Welcome to EP_VM Vagrant dev environment!"

    # Network
    ep_vm.vm.network "private_network", ip: "10.1.9.164" #PRO TIP: If you are in VPN network, private_network will not work. Comment out this line and use "localhost" to access the containers
    # ep_vm.vm.network "forwarded_port", guest: 9988, host: 9988
    # ep_vm.vm.network "forwarded_port", guest: 8080, host: 8080

    # Synced folders
    # mount Projects directory (absolte path)
    ep_vm.vm.synced_folder "C:\\Users\\Finn\\Documents\\workspace\\Projects", "/usr/local/src/projects", type: "virtualbox"
  end
end
