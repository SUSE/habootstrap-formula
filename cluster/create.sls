{%- from "cluster/map.jinja" import cluster with context -%}
{%- from "cluster/macros/get_crmsh_lock_file.sls" import get_crmsh_lock_file with context %}

bootstrap-the-cluster:
  crm.cluster_initialized:
     - name: {{ cluster.name }}
     {% if cluster.watchdog is defined %}
     {% if cluster.watchdog.device is defined %}
     - watchdog: {{ cluster.watchdog.device }}
     {% endif %}
     {% endif %}
     {% if cluster.interface is defined %}
     - interface: {{ cluster.interface }}
     {% endif %}
     {% if cluster.unicast is defined %}
     - unicast: {{ cluster.unicast }}
     {% endif %}
     {% if cluster.admin_ip is defined %}
     - admin_ip: {{ cluster.admin_ip }}
     {% endif %}
     {% if cluster.sbd is defined and cluster.sbd.device is defined %}
     {% if cluster.sbd.device is sameas false %}
     - sbd: True
     {% else %}
     - sbd_dev: {{ cluster.sbd.device|json }}
     {% endif %}
     {% endif %}
     {% if cluster.qdevice is defined %}
     {% if cluster.qdevice.qnetd_hostname is defined %}
     - qnetd_hostname: {{ cluster.qdevice.qnetd_hostname }}
     {% endif %}
     {% endif %}

{% if cluster.corosync is defined %}
# Claim the lock again. The cluster creation and corosync update must be executed atomically
# The next command gets the crmsh lock folder (it has changed over time, so better to get it dynamically)
# The lock folder looks like: /tmp/.crmsh_lock_directory or /run/.crmsh_lock_directory
# If for some reason, any other node is able to acquire the lock before, the state will wait until it is free again
claim-lock:
  cmd.run:
    - name: until mkdir -v {{ get_crmsh_lock_file() }};do sleep 5;done
    - timeout: 300
{% endif %}

hawk:
  service.running:
    - enable: True
    - require:
        - bootstrap-the-cluster
