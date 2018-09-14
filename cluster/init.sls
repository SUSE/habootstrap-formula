{% from "cluster/map.jinja" import cluster with context %}
{% set host = grains['host'] %}

{% if cluster.init == host %}

include:
  - .create

{% elif cluster.remove is defined and host in cluster.remove %}

include:
  - .remove

{% else %}

include:
  - .join

{% endif %}
