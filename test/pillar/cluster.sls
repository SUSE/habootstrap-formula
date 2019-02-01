cluster:
  init: node1
  admin_ip: 192.168.121.50
  interface: eth0
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: /dev/vdb
  ntp: pool.ntp.org
  sshkeys:
    overwrite: true
    password: vagrant
