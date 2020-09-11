{%- from "cluster/map.jinja" import cluster with context -%}

{% set lock_dir = '/var/tmp/habootstrap_join.lock' %}

wait-for-cluster:
  http.wait_for_successful_query:
    - name: 'https://{{ cluster.init }}:7630/monitor?0'
    - request_interval: 5
    - status: 200
    - verify_ssl: false
    - wait_for: {{ cluster.join_timeout }}

wait-for-total-initialization:
  cmd.run:
    - name: 'sleep {{ cluster.wait_for_initialization }}'
    - require:
      - wait-for-cluster

check-ssh-connection-availability:
  cmd.run:
    - name: ssh -o StrictHostKeyChecking=no -o EscapeChar=none -o ConnectTimeout=15 -T -o Batchmode=yes {{ cluster.init }} true
    - require:
      - wait-for-total-initialization

acquire-lock-cluster:
  cmd.run:
    - name: until ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no 'mkdir {{ lock_dir }}';do sleep 10;done
    - timeout: {{ cluster.join_timeout }}
    - output_loglevel: quiet
    - hide_output: True
    - require:
      - check-ssh-connection-availability

join-the-cluster:
  crm.cluster_joined:
     - name: {{ cluster.init }}
     {% if cluster.watchdog is defined %}
     {% if cluster.watchdog.device is defined %}
     - watchdog: {{ cluster.watchdog.device }}
     {% endif %}
     {% endif %}
     {% if cluster.interface is defined %}
     - interface: {{ cluster.interface }}
     {% endif %}
     - require:
       - acquire-lock-cluster

release-lock-cluster:
  cmd.run:
    - name: ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no 'rm -rf {{ lock_dir }}'
    - require:
      - acquire-lock-cluster

hawk:
  service.running:
    - enable: True
    - require:
        - join-the-cluster
