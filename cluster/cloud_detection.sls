# crmsh must exist to run crm.detect_cloud
{% do salt['pkg.install'](name='crmsh') %}
{% do salt['grains.set']('cloud_provider', salt['crm.detect_cloud']()) %}

{% if grains['cloud_provider'] == 'google-cloud-platform' %}
{% do salt['grains.set']('gcp_instance_id', salt['http.query'](url='http://metadata.google.internal/computeMetadata/v1/instance/id', header_dict={"Metadata-Flavor": "Google"})['body']) %}
{% do salt['grains.set']('gcp_instance_name', salt['http.query'](url='http://metadata.google.internal/computeMetadata/v1/instance/name', header_dict={"Metadata-Flavor": "Google"})['body']) %}
{% endif %}
