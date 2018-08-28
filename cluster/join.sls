{%- from "cluster/map.jinja" import cluster with context -%}
{% set join_args = "-y --c " + cluster.join_ip %}
{% if cluster.watchdog is defined %}
  {% set join_args = join_args + " -w " + cluster.watchdog %}
{% endif %}
{% if cluster.interface is defined %}
  {% set join_args = join_args + " -i " + cluster.interface %}
{% endif %}

wait-for-cluster:
  http.wait_for_successful_query:
    - name: 'https://{{ cluster.join_ip }}:7630/monitor?0'
    - request_interval: 5
    - status: 200
    - verify_ssl: false

join-the-cluster:
  cmd.script:
    - name: /usr/sbin/crm cluster join {{ join_args }}
    - unless: systemctl -q is-active pacemaker
    - require:
        - http: wait-for-cluster

hawk:
  service.running:
    - enable: True
    - require:
        - cmd: join-the-cluster
