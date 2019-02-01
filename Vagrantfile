# -*- mode: ruby -*-
# vi: set ft=ruby :

# NET_IP is used as the base private network
# between the cluster nodes. To avoid collisions
# with any other networks you have configured,
# you can modify this. However, it will also be
# necessary to update the salt configuration in
# test/ which hard-codes the IP addresses of the
# nodes.
NET_IP = "10.13.38"

# Master node configuration
def configure_master(master_config, idx, roles, memory, cpus)
  master_config.vm.network :private_network, ip: "#{NET_IP}.#{10 + idx}"
  master_config.vm.provider :libvirt do |provider, override|
    provider.memory = memory
    provider.cpus = cpus
    provider.graphics_port = 9200 + idx
  end

  master_config.vm.synced_folder "./test/salt", "/srv/salt", type: 'rsync'
  master_config.vm.synced_folder "./test/pillar", "/srv/pillar", type: 'rsync'
  master_config.vm.synced_folder "./cluster", "/srv/salt/cluster", type: 'rsync'

  # salt-master must be installed this way, as install_master option does not work properly for thi distro
  master_config.vm.provision "shell", inline: "zypper --non-interactive --gpg-auto-import-keys ref;zypper --gpg-auto-import-keys in -y -l salt-master"

  master_config.vm.provision :salt do |salt|
    salt.master_config = "test/config/etc/master"
    salt.master_key = "test/config/sshkeys/vagrant"
    salt.master_pub = "test/config/sshkeys/vagrant.pub"
    # Add cluster nodes ssh public keys
    salt.seed_master = {
                        "node1" => "test/config/sshkeys/vagrant.pub",
                        "node2" => "test/config/sshkeys/vagrant.pub",
                        "node3" => "test/config/sshkeys/vagrant.pub"
                       }

    salt.install_type = "stable"
    salt.install_master = true
    salt.verbose = true
    salt.colorize = true
    salt.bootstrap_options = "-P -c /tmp"
  end

  # Change hacluster user's shell from nologin to /bin/bash to avoid issues with bindfs
  master_config.vm.provision "shell", inline: "chsh -s /bin/bash hacluster"

end

# Minoin node configuration
def configure_minion(minion_config, idx, roles, memory, cpus)
  minion_config.vm.network :private_network, ip: "#{NET_IP}.#{10 + idx + 1}"
  minion_config.vm.network :forwarded_port, guest: 7630, host: 7630 + idx
  minion_config.vm.provider :libvirt do |provider, override|
    provider.memory = memory
    provider.cpus = cpus
    provider.graphics_port = 9200 + idx + 1
  end

  minion_config.vm.provider :libvirt do |lv|
    lv.storage :file, type: "raw", size: "100M", path: "sbd", allow_existing: true, shareable: true, cache: "none"
  end

  minion_config.vm.provision :salt do |salt|
    salt.minion_id = "node#{idx}"
    salt.minion_config = "test/config/etc/minion"
    salt.minion_key = "test/config/sshkeys/vagrant"
    salt.minion_pub = "test/config/sshkeys/vagrant.pub"
    salt.install_type = "stable"
    salt.verbose = true
    salt.colorize = true
    salt.bootstrap_options = "-P -c /tmp"
  end

  # Change hacluster user's shell from nologin to /bin/bash to avoid issues with bindfs
  minion_config.vm.provision "shell", inline: "chsh -s /bin/bash hacluster"
  minion_config.vm.provision "shell", inline: "zypper rr systemsmanagement-salt"

end

Vagrant.configure("2") do |config|

  config.vm.box = "hawk/tumbleweed-ha"
  config.vm.box_version = "1.1.3"
  config.vm.box_check_update = true
  config.ssh.insert_key = false

  config.vm.synced_folder './', '/vagrant', type: 'rsync'

  # node1: salt master
  config.vm.define :master, primary: true do |machine|
    machine.vm.hostname = "master"
    configure_master machine, 1, ["base", "node"], 768, 1
  end

  # node1: cluster create
  # node2: cluster join
  # node3: cluster join
  # update to add more nodes
  1.upto(3).each do |i|
    config.vm.define "node#{i}" do |machine|
      machine.vm.hostname = "node#{i}"
      configure_minion machine, i, ["base", "node"], 768, 1
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
