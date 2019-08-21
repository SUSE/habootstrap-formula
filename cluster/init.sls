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
{% if cluster.sshkeys is defined  %}
{% if cluster.sshkeys.password is defined %}
  - .sshkeys
{% endif %}
{% endif %}
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
{% if cluster.ha_exporter is defined %}
  - .monitoring
{% endif %}
