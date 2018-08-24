{%- from "cluster/map.jinja" import cluster with context -%}

# Run the bootstrap
salt://cluster/files/create.sh:
  cmd.script:
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
        {% if cluster.admin_ip is defined %}
        - ADMIN_IP: {{ cluster.admin_ip }}
        {% endif %}
        {% if cluster.unicast is defined and cluster.unicast %}
        - UNICAST: "yes"
        {% endif %}

hawk:
  service.running:
    - enable: True
    - require:
        - cmd: salt://cluster/files/create.sh
