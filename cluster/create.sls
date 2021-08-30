{%- from "cluster/map.jinja" import cluster with context -%}

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
     {% if cluster.ocfs2 is defined and cluster.ocfs2.device is defined %}
     - ocfs2_dev: {{ cluster.ocfs2.device }}
     {% if cluster.ocfs2.mount is defined %}
     - ocfs2_mount: {{ cluster.ocfs2.mount }}
     {% endif %}
     {% endif %}
     {% if cluster.qdevice is defined %}
     {% if cluster.qdevice.qnetd_hostname is defined %}
     - qnetd_hostname: {{ cluster.qdevice.qnetd_hostname }}
     {% endif %}
     {% endif %}

hawk:
  service.running:
    - enable: True
    - require:
        - bootstrap-the-cluster
