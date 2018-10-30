{% set cluster = salt['pillar.get']('cluster') %}
{% set host = grains['host'] %}

{% if cluster.init == host %}

node authorization:
  ssh_auth.present:
    - user: root
    - source: /vagrant/test/config/sshkeys/vagrant.pub

{% else %}

create ssh directory:
 file.directory:
   - name: /root/.ssh
   - user: root
   - group: root
   - mode: 600

copy private key:
  file.managed:
    - name: /root/.ssh/id_rsa
    - source: /vagrant/test/config/sshkeys/vagrant
    - user: root
    - group: root
    - mode: 600

copy public key:
  file.copy:
    - name: /root/.ssh/id_rsa.pub
    - source: /vagrant/test/config/sshkeys/vagrant.pub
    - user: root
    - group: root
    - mode: 644

{% endif %}
