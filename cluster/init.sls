{% from "cluster/map.jinja" import cluster with context %}

{% if cluster.mode == "init" %}

include:
  - .create

{% elif cluster.mode == "join" %}

include:
  - .join

{% elif cluster.mode == "remove" %}

include:
  - .remove

{% endif %}
