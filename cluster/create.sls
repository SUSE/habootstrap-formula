{%- from "cluster/map.jinja" import cluster with context -%}

# Run the bootstrap
bootstrap-cluster:
  cmd.run:
    - source: salt://cluster/files/create.sh
    - env:
        - NAME: {{ cluster.name }}
        {% if cluster.watchdog is defined %}
        - WATCHDOG: {{ cluster.watchdog }}
        {% endif %}
        {% if cluster.interface is defined %}
        - INTERFACE: {{ cluster.interface }}
        {% endif %}
        {% if cluster.sbd is defined %}
        - SBD: 1
        {% if cluster.sbd.device is defined %}
        - SBD_DEVICE: {{ cluster.sbd.device }}
        {% endif %}
        {% endif %}

include:
  - .service
