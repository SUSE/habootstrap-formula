cluster:
  init: node1
  admin_ip: 192.168.121.50
  interface: eth0
  watchdog:
    module: softdog
    device: /dev/watchdog
  ntp: pool.ntp.org
  sshkeys:
    password: vagrant
