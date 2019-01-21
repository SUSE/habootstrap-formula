{%- from "cluster/map.jinja" import cluster with context -%}

bootstrap-the-cluster:
  crm.cluster_initialized:
     - name: {{ cluster.name }}
     {% if cluster.watchdog is defined %}
     - watchdog: {{ cluster.watchdog }}
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
     - sbd: {{ cluster.sbd }}
     {% if cluster.sbd.device is defined %}
     - sbd_dev: {{ cluster.sbd.device }}
     {% endif %}
     {% endif %}

{% if cluster.configure is defined %}
configure-the-cluster:
  crm.cluster_configured:
    - method: {{ cluster.configure.method }}
    - url: {{ cluster.configure.url }}
    {% if cluster.configure.is_xml is defined %}
    - is_xml: {{ cluster.configure.is_xml }}
    {% endif %}
    - require:
        - bootstrap-the-cluster
{% endif %}

hawk:
  service.running:
    - enable: True
    - require:
        - bootstrap-the-cluster
