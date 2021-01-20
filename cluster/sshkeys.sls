{% from "cluster/map.jinja" import cluster with context %}
{% set host = grains['host'] %}

create_ssh_directory:
 file.directory:
   - name: /root/.ssh
   - user: root
   - group: root
   - mode: 600
   - require:
     - wait-for-total-initialization

{% if cluster.sshkeys.get('password', False) %}
{% set password = cluster.sshkeys.get('password') %}

create_key:
  cmd.run:
    - name: yes y | sudo ssh-keygen -f /root/.ssh/id_rsa -C 'Cluster Internal on {{ grains['host'] }}' -N ''
    - unless: 'test -e /root/.ssh/id_rsa'
    - require:
      - wait-for-total-initialization

copy_ask_pass:
  file.managed:
    - name: /tmp/ssh_askpass
    - source: salt://cluster/support/ssh_askpass
    - user: root
    - group: root
    - mode: 755
    - require:
      - wait-for-total-initialization

copy_ssh_pub:
  cmd.run:
    - name: setsid scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
            /root/.ssh/id_rsa.pub root@{{ cluster.init }}:/root/.ssh/{{ grains['host'] }}_id_rsa.pub
    - env:
      - SSH_ASKPASS: /tmp/ssh_askpass
      - DISPLAY: :0
      - PASS: {{ password }}
    - require:
      - copy_ask_pass

authorize_key:
  cmd.run:
    - name: setsid ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no
            'cat /root/.ssh/{{ grains['host'] }}_id_rsa.pub >> /root/.ssh/authorized_keys'
    - unless: setsid ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no
              'grep /root/.ssh/{{ grains['host'] }}_id_rsa.pub -f /root/.ssh/authorized_keys'
    - env:
      - SSH_ASKPASS: /tmp/ssh_askpass
      - DISPLAY: :0
      - PASS: {{ password }}
    - require:
      - copy_ssh_pub

rm_ssh_pub:
  cmd.run:
    - name: setsid ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no
            'rm /root/.ssh/{{ grains['host'] }}_id_rsa.pub'
    - env:
      - SSH_ASKPASS: /tmp/ssh_askpass
      - DISPLAY: :0
      - PASS: {{ password }}
    - require:
      - copy_ssh_pub

{% endif %}
