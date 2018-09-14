salt.packages:
  pkg.installed:
    - pkgs:
        - salt
        - salt-master

/etc/salt/master:
  file.managed:
    - source: salt://files/master
    - user: root
    - group: root
    - mode: 644

salt-master:
  service.running:
    - enable: True
    - watch:
      - pkg: salt.packages
      - file: /etc/salt/master

/srv/salt/top.sls:
  file.managed:
    - source: salt://files/top.sls
    - user: root
    - group: root
    - mode: 644

/srv/pillar/top.sls:
  file.managed:
    - source: salt://files/pillar.top.sls
    - user: root
    - group: root
    - mode: 644

/srv/pillar/cluster.sls:
  file.managed:
    - source: salt://files/pillar.cluster.sls
    - user: root
    - group: root
    - mode: 644
