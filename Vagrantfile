# Generic headless Ubuntu Trusty.  Type “vagrant up” to provision and launch box.
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
    # vb.gui = true
    # Use VBoxManage to customize the VM. For example to change memory:
      vb.customize ["modifyvm", :id, "--memory", "4096"]
  end
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false
  config.vm.hostname = "Trusty64-server"
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
  config.vm.provision "shell", path: "bootstrap.sh"
  config.vm.synced_folder "oct/", "/home/vagrant/work"
  config.vm.synced_folder ".", "/vagrant", disabled: true
end
