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

{% if cluster.configure is defined %}
{% set url = none %}
{% if cluster.configure.template is defined %}
{% set url = cluster.configure.template.destination|default('/tmp/cluster.config') %}
{{ url }}:
  file.managed:
    - source: {{ cluster.configure.template.source }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
{% endif %}

configure-the-cluster:
  crm.cluster_configured:
    - name: {{ cluster.configure.method }}
    - url: {{ cluster.configure.url|default(url) }}
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
