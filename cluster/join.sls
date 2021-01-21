{%- from "cluster/map.jinja" import cluster with context -%}

check-ssh-connection-availability:
  cmd.run:
    - name: ssh -o StrictHostKeyChecking=no -o EscapeChar=none -o ConnectTimeout=15 -T -o Batchmode=yes {{ cluster.init }} true
    - require:
      - wait-for-total-initialization

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
       - check-ssh-connection-availability

hawk:
  service.running:
    - enable: True
    - require:
        - join-the-cluster
