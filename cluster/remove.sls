remove-the-cluster-node:
  crm.cluster_absent:
     - name: {{ grains['host'] }}
