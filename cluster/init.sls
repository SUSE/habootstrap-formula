{% from "cluster/map.jinja" import cluster with context %}
{% set host = grains['host'] %}

{% if cluster.init == host %}

include:
  - .create

{% elif host in cluster.remove %}

include:
  - .remove

{% else %}

include:
  - .join

{% endif %}
