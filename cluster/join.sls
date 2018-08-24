{%- from "cluster/map.jinja" import cluster with context -%}

# Attempt to join the cluster
salt://cluster/files/join.sh:
  cmd.script:
    - env:
        - IP: {{ cluster.join_ip }}
        {% if cluster.watchdog is defined %}
        - WATCHDOG: {{ cluster.watchdog }}
        {% endif %}
        {% if cluster.interface is defined %}
        - INTERFACE: {{ cluster.interface }}
        {% endif %}

hawk:
  service.running:
    - enable: True
    - require:
        - cmd: salt://cluster/files/join.sh
