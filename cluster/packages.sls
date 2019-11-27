#required packages to install HA cluster

{%- from "cluster/map.jinja" import cluster with context -%}

{% set pattern_available = 1 %}
{% if grains['os_family'] == 'Suse' %}
{% set pattern_available = salt['cmd.retcode']('zypper search patterns-ha-ha_sles') %}
{% endif %}

{% if pattern_available == 0 %}
# refresh is disabled to avoid errors during the call
{% set repo = salt['pkg.info_available']('patterns-ha-ha_sles', refresh=False)['patterns-ha-ha_sles']['repository'] %}
patterns-ha-ha_sles:
  pkg.installed:
    - fromrepo: {{ repo }}
    - retry:
        attempts: 3
        interval: 15

{% else %}

install_cluster_packages:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
    - pkgs:
      - corosync
      - crmsh
      - csync2
      - drbd
      - drbd-utils
      - fence-agents
      - ha-cluster-bootstrap
      - hawk2
      - hawk-apiserver
      - pacemaker
      - resource-agents
      - sbd

{% endif %}

{% if grains['provider'] == "azure" %}
# Install socat utility on Azure platform (to replace netcat)
install_additional_packages_azure:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
    - pkgs:
      - socat
{% endif %}