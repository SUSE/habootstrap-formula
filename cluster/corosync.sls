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

# To prevent failing "crm configre load" commands after corosync restart
wait-for-corosync-restart:
  cmd.run:
    - name: 'crm cluster wait_for_startup'
    - require:
      - corosync_service
    - retry:
        attempts: 20
        interval: 10
