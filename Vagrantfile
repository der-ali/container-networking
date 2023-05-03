# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT
echo "cd /vagrant" >> /home/vagrant/.bashrc
echo "ln -sf /vagrant/.vim /home/vagrant/.vim" >> /home/vagrant/.bashrc
echo "ln -sf /vagrant/.vimrc /home/vagrant/.vimrc" >> /home/vagrant/.bashrc
apt update
apt install -y net-tools bird2 golang llvm libbpf-dev clang  gcc-multilib
SCRIPT
MasterCount = 2
Vagrant.configure(2) do |config|
  (1..MasterCount).each do |i|
  config.vm.define "node0#{i}" do |s1|
      s1.vm.box = "alvistack/ubuntu-23.04"
      s1.vm.network :private_network, ip: "10.0.0.#{i}0", virtualbox__intnet: "network3"
      s1.vm.hostname = "node0#{i}"
      s1.vm.provision "shell", inline: $script
      s1.vm.provider "virtualbox" do |v|
        v.name = "node0#{i}"
      end
    end
  end
  config.vm.box_check_update = false
  config.vbguest.auto_update = false
  config.vm.synced_folder ".", "/vagrant"
end
