#required packages to install HA cluster

{% set pattern_available = 1 %}
{% if grains['os_family'] == 'Suse' %}
{% set pattern_available = salt['cmd.retcode']('zypper search patterns-ha-ha_sles') %}
{% endif %}

{% if pattern_available == 0 %}
{% set repo = salt['pkg.info_available']('patterns-ha-ha_sles')['patterns-ha-ha_sles']['repository'] %}
patterns-ha-ha_sles:
  pkg.installed:
    - fromrepo: {{ repo }}
    - retry:
        attempts: 3
        interval: 15

{% else %}

install_cluster_packages:
  pkg.installed:
    - pkgs:
      - crmsh
      - ha-cluster-bootstrap
      - hawk2

{% endif %}
