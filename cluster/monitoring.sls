/usr/share/hawk-apiserver/json.config:
  file.managed:
    - source: salt://cluster/templates/hawk_apiserver_json_config.j2
    - template: jinja
    - mode: 644
    - makedirs: True


/etc/systemd/system/hawk-apiserver.service:
  file.managed:
    - source: salt://cluster/templates/hawk_apiserver.service
    - user: root
    - group: root
    - mode: 644
    - require:
        - file: /usr/share/hawk-apiserver/json.config

hawk-apiserver:
  service.running:
    - enable: True