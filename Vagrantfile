# -*- mode: ruby -*-
# vi: set ft=ruby :

def host_bind_address
  ENV['VAGRANT_INSECURE_FORWARDS'] =~ /^(y(es)?|true|on)$/i ? '*' : '127.0.0.1'
end

# Shared configuration for all VMs
def configure_machine(machine, idx, roles, memory, cpus)
  machine.vm.network :private_network, ip: "10.13.38.#{10 + idx}"

  machine.vm.provision "shell", inline: "zypper -n rr systemsmanagement-salt; zypper in -y -l salt"

  machine.vm.provision :salt do |salt|
    salt.masterless = true
    salt.minion_config = "test/salt/etc/minion"
    salt.run_highstate = true
    #salt.verbose = true
    salt.no_minion = true
    salt.always_install = false
    salt.install_type = "stable"
    salt.bootstrap_options = "-b"
  end

  # Change hacluster user's shell from nologin to /bin/bash to avoid issues with bindfs
  machine.vm.provision "shell", inline: "chsh -s /bin/bash hacluster"

  machine.vm.provider :virtualbox do |provider, override|
    provider.memory = memory
    provider.cpus = cpus
    provider.name = "bootstrap-#{machine.vm.hostname}"
  end

  machine.vm.provider :libvirt do |provider, override|
    provider.memory = memory
    provider.cpus = cpus
    provider.graphics_port = 9200 + idx
  end
end

Vagrant.configure("2") do |config|
  #unless Vagrant.has_plugin?("vagrant-bindfs")
  #  warn 'Missing bindfs plugin! Please install using vagrant plugin install vagrant-bindfs'
  #end

  config.vm.box = "hawk/tumbleweed-ha"
  config.vm.box_version = "1.1.3"
  config.vm.box_check_update = true
  config.ssh.insert_key = false


  config.vm.synced_folder './', '/vagrant', type: 'rsync'
  #config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_udp: false, mount_options: ["rw", "noatime", "async"]
  #config.bindfs.bind_folder "/vagrant", "/vagrant", force_user: "hacluster", force_group: "haclient", perms: "u=rwX:g=rwXD:o=rXD", after: :provision

  # node1: salt master
  # node2: cluster create
  # node3: cluster join
  1.upto(3).each do |i|
    config.vm.define "node#{i}", primary: (i == 1), autostart: true do |machine|
      machine.vm.hostname = "node#{i}"
      configure_machine machine, i, ["base", "node"], 768, 1
    end
  end

  remote_vmhost = ENV["VAGRANT_HOST"]

  config.vm.provider :libvirt do |provider, override|
    unless remote_vmhost.nil?
      provider.connect_via_ssh = true
      provider.host = remote_vmhost.strip
      provider.username = "root"
    end
    provider.cpu_mode = 'host-passthrough'
    provider.storage_pool_name = "default"
    provider.management_network_name = "vagrant"
  end
end
