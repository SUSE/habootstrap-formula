{% from "cluster/map.jinja" import cluster with context %}
{% set host = grains['host'] %}

create_ssh_directory:
 file.directory:
   - name: /root/.ssh
   - user: root
   - group: root
   - mode: 600
   - require:
     - wait-for-cluster

{% if cluster.sshkeys.get('password', False) %}
{% set password = cluster.sshkeys.get('password') %}

create_key:
  cmd.run:
    - name: yes y | sudo ssh-keygen -f /root/.ssh/id_rsa -C 'Cluster Internal on {{ grains['host'] }}' -N ''
    - unless: 'test -e /root/.ssh/id_rsa'
    - require:
      - wait-for-cluster

copy_ask_pass:
  file.managed:
    - name: /tmp/ssh_askpass
    - source: salt://cluster/support/ssh_askpass
    - user: root
    - group: root
    - mode: 755
    - require:
      - wait-for-cluster

authorize_key:
  cmd.run:
    - name: setsid ssh-copy-id root@{{ cluster.init }}
    - unless: setsid ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no
              'grep /root/.ssh/{{ grains['host'] }}_id_rsa.pub -f /root/.ssh/authorized_keys'
    - env:
      - SSH_ASKPASS: /tmp/ssh_askpass
      - DISPLAY: :0
      - PASS: {{ password }}
    - require:
      - copy_ask_pass

{% endif %}
