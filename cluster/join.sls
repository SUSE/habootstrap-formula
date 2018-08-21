{%- from "cluster/map.jinja" import cluster with context -%}

# Attempt to join the cluster
join-cluster:
  cmd.run:
    - source: salt://cluster/files/join.sh
    - env:
        - IP: {{ TODO }}
        {% if cluster.watchdog is defined %}
        - WATCHDOG: {{ cluster.watchdog }}
        {% endif %}
        {% if cluster.interface is defined %}
        - INTERFACE: {{ cluster.interface }}
        {% endif %}

include:
  - .service
