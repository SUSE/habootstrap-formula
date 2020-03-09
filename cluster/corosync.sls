{%- from "cluster/map.jinja" import cluster with context -%}

customize_corosync:
  crm.corosync_updated:
    - name: /etc/corosync/corosync.conf
    - data: {{ cluster.corosync|json }}

corosync_service:
  service.running:
    - name: corosync
    - restart: True
    - onchanges:
      - customize_corosync
    - watch:
      - customize_corosync
