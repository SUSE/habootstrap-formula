{%- from "cluster/map.jinja" import cluster with context -%}

remove-the-cluster-node:
  cmd.run:
    - name: /usr/sbin/crm cluster remove -yF {{ grains['host'] }}
    - onlyif: systemctl -q is-active pacemaker

