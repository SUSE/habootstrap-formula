#! /bin/bash

# this script is intended to be executed via PRs travis CI
set -e

## this will generate the pillar
function generate_cluster_pillar {
  METHOD="$1"
  cat > test/pillar/cluster.sls <<EOF
  cluster:
    name: 'hacluster'
    $METHOD
    remove: ['hana03']
    interface: 'eth1'
    watchdog:
      module: softdog
      device: /dev/watchdog
    sbd:
      device: '/dev/vdc'
    ntp: pool.ntp.org
    sshkeys:
      overwrite: true
      password: linux
    resource_agents:
      - SAPHanaSR
    hacluster_password: mypassword
    configure:
      method: update
      template:
        source: /srv/salt/hana/templates/scale_up_resources.j2
        parameters:
          sid: prd
          instance: 00
          virtual_ip: 192.168.107.50
          virtual_ip_mask: 24
          platform: libvirt
          prefer_takeover: true
          auto_register: false
EOF
}



echo "==========================================="
echo " generating pillar and top.sls conf files "
echo "==========================================="

generate_cluster_pillar "init: 'hana01'"
cat > top.sls <<EOF
base:
  '*':
    - cluster
EOF

echo "top.sls and pillar --> DONE"
echo


echo "==========================================="
echo "Using primary host - Running init"
echo "==========================================="

cat >grains <<EOF
host: hana01
EOF

cat >minion <<EOF
root_dir: $PWD
id: travis
EOF

sudo salt-call state.show_highstate --local --file-root=./ --config-dir=. --pillar-root=test/pillar  --retcode-passthrough -l debug

echo
echo "==========================================="
echo " Using secondary host - Running join       "
echo "==========================================="

generate_cluster_pillar "init: 'hana01'"
cat >grains <<EOF
host: hana02
EOF

cat >minion <<EOF
root_dir: $PWD
id: travis
EOF

sudo salt-call state.show_highstate --local --file-root=./ --config-dir=. --pillar-root=test/pillar --retcode-passthrough -l debug

echo
echo "==========================================="
echo " Using third host - Running remove      "
echo "==========================================="

generate_cluster_pillar "init: 'hana01'"
cat >grains <<EOF
host: hana03
EOF

cat >minion <<EOF
root_dir: $PWD
id: travis
EOF

sudo salt-call state.show_highstate --local --file-root=./ --config-dir=. --pillar-root=test/pillar --retcode-passthrough -l debug
