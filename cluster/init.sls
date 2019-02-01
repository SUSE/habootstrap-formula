{% from "cluster/map.jinja" import cluster with context %}
{% set host = grains['host'] %}

include:
  - .packages
  - .resource_agents
{% if cluster.ntp is defined %}
  - .ntp
{% endif %}
{% if cluster.sshkeys is defined and cluster.sshkeys.password is defined %}
  - .sshkeys
{% endif %}
{% if cluster.watchdog.module is defined %}
  - .watchdog
{% endif %}
{% if cluster.init == host %}
  - .create
{% elif cluster.remove is defined and host in cluster.remove %}
  - .remove
{% else %}
  - .join
{% endif %}
