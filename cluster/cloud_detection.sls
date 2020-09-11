install_crmsh:
  pkg.installed:
    - name: crmsh
    - retry:
        attempts: 3
        interval: 15

# This state will set the next grains are required by this formula and used configuration templates
# All providers: cloud_provider
# Only gcp: gcp_instance_id, gcp_instance_name
set_cloud_data_in_grains:
  crm.cloud_grains_present:
    - require:
      - install_crmsh
