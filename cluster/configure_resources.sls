{%- from "cluster/map.jinja" import cluster with context -%}
{% set host = grains['host'] %}

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
        {% if cluster.init == host %}
        - bootstrap-the-cluster
        {% else %}
        - join-the-cluster
        {% endif %}
{% endif %}
