{% from "cluster/map.jinja" import cluster with context %}
{% set host = grains['host'] %}
{% set password = cluster.sshkeys.password %}

create_ssh_directory:
 file.directory:
   - name: /root/.ssh
   - user: root
   - group: root
   - mode: 600

{% if cluster.init != host %}

{% if cluster.sshkeys.overwrite is defined and cluster.sshkeys.overwrite is sameas true %}
create_key:
  cmd.run:
    - name: yes y | sudo ssh-keygen -f /root/.ssh/id_rsa -C 'Initial key' -N ''
{% endif %}

add_network_repo:
  pkgrepo.managed:
    - name: network
    - baseurl: https://download.opensuse.org/repositories/network/SLE_12_SP3
    - gpgautoimport: True

install_sshpass:
  pkg.installed:
    - name: sshpass
    - refresh: False
    - fromrepo: network
    - require:
      - add_network_repo

copy_ssh_pub:
  cmd.run:
    - name: sshpass -p '{{ password }}' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
            /root/.ssh/id_rsa.pub root@{{ cluster.init }}:/root/.ssh/{{ grains['host'] }}_id_rsa.pub
    - require:
      - install_sshpass

authorize_key:
  cmd.run:
    - name: sshpass -p '{{ password }}' ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no
            'cat /root/.ssh/{{ grains['host'] }}_id_rsa.pub >> /root/.ssh/authorized_keys'
    - unless: sshpass -p '{{ password }}' ssh -T root@{{ cluster.init }}
              'grep /root/.ssh/{{ grains['host'] }}_id_rsa.pub -f /root/.ssh/authorized_keys'
    - require:
      - copy_ssh_pub

rm_ssh_pub:
  cmd.run:
    - name: sshpass -p '{{ password }}' ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no
            'rm /root/.ssh/{{ grains['host'] }}_id_rsa.pub'
    - require:
      - copy_ssh_pub

{% endif %}
