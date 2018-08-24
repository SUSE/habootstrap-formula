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

/srv/pillar/cluster_init.sls:
  file.managed:
    - source: salt://files/pillar.cluster_init.sls
    - user: root
    - group: root
    - mode: 644

/srv/pillar/cluster_join.sls:
  file.managed:
    - source: salt://files/pillar.cluster_join.sls
    - user: root
    - group: root
    - mode: 644
