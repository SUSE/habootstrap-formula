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
{% elif host in cluster.remove %}
  - .remove
{% else %}
  - .join
{% endif %}
{% if host not in cluster.remove %}
  - .configure_resources
{% endif %}
{% if cluster.hacluster_password is defined %}
  - .hacluster_user
{% endif %}
{% if cluster.ha_exporter is sameas true %}
  - .monitoring
{% endif %}
