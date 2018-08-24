salt:
  pkg.installed

/etc/salt/minion:
  file.managed:
    - source: salt://files/minion
    - user: root
    - group: root
    - mode: 644

salt-minion:
  service.running:
    - enable: True
    - watch:
        - pkg: salt
        - file: /etc/salt/minion
