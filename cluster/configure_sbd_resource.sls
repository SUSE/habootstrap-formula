{%- from "cluster/map.jinja" import cluster with context -%}
{% set host = grains['host'] %}

{% if cluster.sbd is defined and cluster.sbd.configure_resource is defined %}

create-sbd-resource-configuration:
  file.managed:
    - name: /tmp/sbd.config
    - source: salt://cluster/templates/sbd_resource.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        configure: {{ cluster.sbd.configure_resource|yaml }}

configure-sbd-resource:
  crm.cluster_configured:
    - name: update
    - url: /tmp/sbd.config
    - is_xml: False
    - force: {{ cluster.sbd.configure_resource.force|default(False) }}
    - require:
      - create-sbd-resource-configuration

{% endif %}
