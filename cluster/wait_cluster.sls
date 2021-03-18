{%- from "cluster/map.jinja" import cluster with context -%}

wait-for-cluster:
  http.wait_for_successful_query:
    - name: 'https://{{ cluster.init }}:7630/monitor?0'
    - request_interval: 5
    - status: 200
    - verify_ssl: false
    - wait_for: {{ cluster.join_timeout }}
