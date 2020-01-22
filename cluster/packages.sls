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

{% if grains['cloud_provider'] == 'microsoft-azure' %}
install_additional_packages_azure:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
    - pkgs:
      - socat
{% elif grains['cloud_provider'] == 'google-cloud-platform' %}
{%- set python_version = 'python' if grains['pythonversion'][0] == 2 else 'python3' %}
install_additional_packages_gcp:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
    - pkgs:
      - {{ python_version }}-google-api-python-client
      - {{ python_version }}-oauth2client-gce
    - resolve_capabilities: true
{% endif %}
