{%- from "cluster/map.jinja" import cluster with context -%}

{% set lock_file = '/var/tmp/crmsh.lock' %}

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

{% if cluster.join_lock %}
acquire-lock-cluster:
  cmd.run:
    - name: ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no '[ ! -f "{{ lock_file }}" ] && touch {{ lock_file }}'
    - retry:
        attempts: 30
        interval: 10
{% endif %}

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
       - wait-for-total-initialization
{%- if cluster.join_lock %}
       - acquire-lock-cluster

release-lock-cluster:
  cmd.run:
    - name: ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no 'rm {{ lock_file }}'
    - require:
      - acquire-lock-cluster
{% endif %}

hawk:
  service.running:
    - enable: True
    - require:
        - join-the-cluster
