{%- from "cluster/map.jinja" import cluster with context -%}

customize_corosync:
  crm.corosync_updated:
    - name: /etc/corosync/corosync.conf
    - data: {{ cluster.corosync|json }}

reload_corosync_configuration:
  cmd.run:
    - name: corosync-cfgtool -R
    - restart: True
    - onchanges:
      - customize_corosync
    - watch:
      - customize_corosync
