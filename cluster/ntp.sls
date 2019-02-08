{%- from "cluster/map.jinja" import cluster with context -%}

ntp_packages:
  pkg.installed:
  - name: ntp

/etc/ntp.conf:
  file.append:
  - text:
    - server {{ cluster.ntp }}

ntpd:
  service.running:
  - enable: True
  - watch:
    - file: /etc/ntp.conf
