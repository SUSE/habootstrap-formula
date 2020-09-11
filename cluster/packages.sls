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

# The next 2 onlyif statements can be improved when salt version 3000 is used
# https://docs.saltstack.com/en/latest/ref/states/requisites.html#onlyif
install_additional_packages_azure:
  pkg.installed:
    - onlyif: cat /etc/salt/grains | grep "cloud_provider:.*microsoft-azure"
    - retry:
        attempts: 3
        interval: 15
    - pkgs:
      - socat

{%- set python_version = 'python' if grains['pythonversion'][0] == 2 else 'python3' %}
install_additional_packages_gcp:
  pkg.installed:
    - onlyif: cat /etc/salt/grains | grep "cloud_provider:.*google-cloud-platform"
    - retry:
        attempts: 3
        interval: 15
    - pkgs:
      - {{ python_version }}-google-api-python-client # Needed by gcp-vpc-move-route and fence_gce
      - {{ python_version }}-google-auth
      - {{ python_version }}-google-auth-httplib2
      - {{ python_version }}-pyroute2 # Needed by gcp-vpc-move-route
    - resolve_capabilities: true
