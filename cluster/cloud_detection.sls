# crmsh must exist to run crm.detect_cloud
{% do salt['pkg.install'](name='crmsh') %}
{% do salt['grains.set']('cloud_provider', salt['crm.detect_cloud']()) %}
