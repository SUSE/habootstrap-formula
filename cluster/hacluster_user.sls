{% from "cluster/map.jinja" import cluster with context %}
{% set host = grains['host'] %}

{% if cluster.remove is not defined or host not in cluster.remove %}
update_hacluster_password:
  user.present:
    - name: hacluster
    - password: {{ cluster.hacluster_password }}
    - hash_password: True
    - require:
      - hawk
{% endif %}
