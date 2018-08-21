{% from "cluster/map.jinja" import cluster with context %}

{% if cluster.mode == "init" %}

include:
  - .create

{% else %}

include:
  - .join

{% endif %}
