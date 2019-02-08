{%- from "cluster/map.jinja" import cluster with context -%}

{{ cluster.watchdog.module }}:
   kmod.present:
     - persist: True
