{%- from "cluster/map.jinja" import cluster with context -%}
{% set create_args = "-y --name " + cluster.name %}
{% if cluster.watchdog is defined %}
  {% set create_args = create_args + " -w " + cluster.watchdog %}
{% endif %}
{% if cluster.interface is defined %}
  {% set create_args = create_args + " -i " + cluster.interface %}
{% endif %}
{% if cluster.admin_ip is defined %}
  {% set create_args = create_args + " -A " + cluster.admin_ip %}
{% endif %}
{% if cluster.unicast is defined and cluster.unicast %}
  {% set create_args = create_args + " -u" %}
{% endif %}
{% if cluster.sbd is defined %}
  {% set create_args = create_args + " --enable-sbd" %}
  {% if cluster.sbd.device is defined %}
    {% set create_args = create_args + " -s " + cluster.sbd.device %}
  {% endif %}
{% endif %}

bootstrap-the-cluster:
  cmd.run:
    - name: /usr/sbin/crm cluster init {{ create_args }}
    - unless: systemctl -q is-active pacemaker

hawk:
  service.running:
    - enable: True
    - require:
        - cmd: bootstrap-the-cluster
