{%- from "cluster/map.jinja" import cluster with context -%}

bootstrap-the-cluster:
  crm.cluster_initialized:
     - name: {{ cluster.name }}
     {% if cluster.watchdog is defined %}
     {% if cluster.watchdog.device is defined %}
     - watchdog: {{ cluster.watchdog.device }}
     {% endif %}
     {% endif %}
     {% if cluster.interface is defined %}
     - interface: {{ cluster.interface }}
     {% endif %}
     {% if cluster.unicast is defined %}
     - unicast: {{ cluster.unicast }}
     {% endif %}
     {% if cluster.admin_ip is defined %}
     - admin_ip: {{ cluster.admin_ip }}
     {% endif %}
     {% if cluster.sbd is defined %}
     - sbd: True
     {% if cluster.sbd.device is defined %}
     - sbd_dev: {{ cluster.sbd.device }}
     {% endif %}
     {% endif %}

hawk:
  service.running:
    - enable: True
    - require:
        - bootstrap-the-cluster
