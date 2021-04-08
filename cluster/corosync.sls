{%- from "cluster/map.jinja" import cluster with context -%}
{%- from "cluster/macros/get_crmsh_lock_file.sls" import get_crmsh_lock_file with context %}

customize_corosync:
  crm.corosync_updated:
    - name: /etc/corosync/corosync.conf
    - data: {{ cluster.corosync|json }}

restart_corosync_service:
  service.running:
    - name: corosync
    - onchanges:
      - customize_corosync
    - watch:
      - customize_corosync

# Release the lock acquired during the create states
release_lock:
  cmd.run:
    - name: rm -rfv {{ get_crmsh_lock_file() }}
