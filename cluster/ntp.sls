{%- from "cluster/map.jinja" import cluster with context -%}

{% if grains['osmajorrelease']|int == 12 %}
ntp:
  pkg.installed

/etc/ntp.conf:
  file.append:
  - text:
    - server {{ cluster.ntp }}

ntpd:
  service.running:
  - enable: True
  - watch:
    - file: /etc/ntp.conf

{% else %} # SLES15
chrony:
  pkg.installed

/etc/chrony.conf:
  file.append:
  - text:
    - server {{ cluster.ntp }}

chronyd:
  service.running:
  - enable: True
  - watch:
    - file:  /etc/chrony.conf
{% endif %}
