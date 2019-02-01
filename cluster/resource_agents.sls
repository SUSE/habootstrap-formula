{%- from "cluster/map.jinja" import cluster with context -%}

{% if cluster.resource_agents is defined and cluster.resource_agents|length>0 %}
install_resource_agents:
  pkg.installed:
    - pkgs:
{% for package in cluster.resource_agents %}
      - {{ package }}
{% endfor %}
{% endif %}
