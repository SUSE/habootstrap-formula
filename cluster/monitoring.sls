prometheus_ha_cluster_exporter:
  pkg.installed:
    - name: prometheus-ha_cluster_exporter

ha_cluster_exporter_service:
  service.running:
    - name: prometheus-ha_cluster_exporter
    - enable: True
    - restart: True
    - require:
      - pkg: prometheus_ha_cluster_exporter
