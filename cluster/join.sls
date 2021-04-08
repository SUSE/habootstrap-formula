{%- from "cluster/map.jinja" import cluster with context -%}
{%- from "cluster/macros/get_crmsh_lock_file.sls" import get_crmsh_lock_file with context %}

check-ssh-connection-availability:
  cmd.run:
    - name: ssh -o StrictHostKeyChecking=no -o EscapeChar=none -o ConnectTimeout=15 -T -o Batchmode=yes {{ cluster.init }} true
    - require:
      - wait-for-cluster

# Check before join if the cluster join lock is free
# This is done in the join itself, but as the init process needs to be atomic the lock usage
# has been extended
check-join-availability:
  cmd.run:
    - name: ssh -T root@{{ cluster.init }} -o StrictHostKeyChecking=no
        "until [ ! -e {{ get_crmsh_lock_file() }} ];do sleep 5; done"
    - timeout: {{ cluster.join_timeout }}
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
       - check-join-availability

hawk:
  service.running:
    - enable: True
    - require:
        - join-the-cluster
