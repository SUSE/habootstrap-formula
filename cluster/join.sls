{%- from "cluster/map.jinja" import cluster with context -%}

wait-for-cluster:
  http.wait_for_successful_query:
    - name: 'https://{{ cluster.init }}:7630/monitor?0'
    - request_interval: 5
    - status: 200
    - verify_ssl: false
    - wait_for: 60

wait-for-total-initialization:
  cmd.run:
    - name: 'sleep 5'
    - require:
      - wait-for-cluster

join-the-cluster:
  crm.cluster_joined:
     - name: {{ cluster.init }}
     {% if cluster.watchdog.device is defined %}
     - watchdog: {{ cluster.watchdog.device }}
     {% endif %}
     {% if cluster.interface is defined %}
     - interface: {{ cluster.interface }}
     {% endif %}
     - require:
         - wait-for-total-initialization

hawk:
  service.running:
    - enable: True
    - require:
        - join-the-cluster
