{% from "cluster/map.jinja" import cluster with context %}

{% if cluster.mode == "create" %}

include:
  - .create

{% else %}

include:
  - .join

{% endif %}
