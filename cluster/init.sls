{% from "cluster/map.jinja" import cluster with context %}
{% set host = grains['host'] %}

include:
  - .pre_validation
{% if cluster.install_packages is sameas true %}
  - .packages
{% endif %}
  - .resource_agents
{% if cluster.ntp is defined %}
  - .ntp
{% endif %}
  - .sshkeys
{% if cluster.watchdog is defined %}
{% if cluster.watchdog.module is defined %}
  - .watchdog
{% endif %}
{% endif %}
{% if cluster.init == host %}
  - .create
{% elif cluster.remove is defined and host in cluster.remove %}
  - .remove
{% else %}
  - .join
{% endif %}
{% if cluster.ha_exporter is sameas true %}
  - .monitoring
{% endif %}
