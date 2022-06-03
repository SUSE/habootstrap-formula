# This is e.g. needed to be run on the initial HANA cluster node to detect a running HANA correctly.
# It follows the maintenance procedures from `man 7 SAPHanaSR_maintenance_examples`.
# Without it, a "end action monitor_clone with rc=8 (0.155.0)" might happen.
# This is somewhat a new behaviour in SAPHanaSR-0.155.0-4.17.1.
#
# It might also be used by any other cluster resource, this is why it is generally available.
#
{%- from "cluster/map.jinja" import cluster with context -%}
{% set host = grains['host'] %}

{% if cluster.init == host %}
{% if cluster.configure is defined and cluster.configure.template is defined and cluster.configure.template.parameters is defined %}
{% set resources = cluster.configure.template.parameters.resources_maintenance|default([]) %}

{% for resource in resources %}

resource_maintenance:
  cmd.run:
    - name: crm resource maintenance {{ resource }} on
    # start after resources are defined
    - require:
      - configure-the-cluster

wait_after_resource_maintenance:
  cmd.run:
    - name: cs_wait_for_idle --sleep 5
    - require:
      - resource_maintenance

resource_refresh:
  cmd.run:
    - name: crm resource refresh {{ resource }}
    - require:
      - wait_after_resource_maintenance

wait_after_resource_refresh:
  cmd.run:
    - name: cs_wait_for_idle --sleep 5
    - require:
      - resource_refresh

resource_maintenance_off:
  cmd.run:
    - name: crm resource maintenance {{ resource }} off
    - require:
      - wait_after_resource_refresh

{% endfor %}
{% endif %}
{% endif %}
