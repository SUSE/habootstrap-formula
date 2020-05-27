{%- from "cluster/map.jinja" import cluster with context -%}
{% set host = grains['host'] %}

include:
  - .configure_sbd_resource

{% if cluster.configure is defined %}

# Configure the cluster properties
{% if cluster.configure.properties is defined and cluster.configure.properties|length>0 %}
configure-cluster-properties:
  crm.cluster_properties_present:
    - properties: {{ cluster.configure.properties|json }}
{% endif %}

# Configure the cluster rsc_defaults
{% if cluster.configure.rsc_defaults is defined and cluster.configure.rsc_defaults|length>0 %}
configure-cluster-rsc-defaults:
  crm.cluster_rsc_defaults_present:
    - rsc_defaults: {{ cluster.configure.rsc_defaults|json }}
{% endif %}

# Configure the cluster op_defaults
{% if cluster.configure.op_defaults is defined and cluster.configure.op_defaults|length>0 %}
configure-cluster-op-defaults:
  crm.cluster_op_defaults_present:
    - op_defaults: {{ cluster.configure.op_defaults|json }}
{% endif %}

# Configure the cluster using a configuration file
{% if cluster.configure.url is defined or cluster.configure.template is defined %}
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
    - name: {{ cluster.configure.method|default("update") }}
    - url: {{ cluster.configure.url|default(url) }}
    - is_xml: {{ cluster.configure.is_xml|default(False) }}
    - force: {{ cluster.configure.force|default(False) }}
    - require:
        {% if cluster.init == host %}
        - bootstrap-the-cluster
        {% else %}
        - join-the-cluster
        {% endif %}
{% endif %}
{% endif %}
