add-saphana-repo:
  pkgrepo.managed:
    - name: saphana
    - baseurl: https://download.opensuse.org/repositories/home:xarbulu:sap-deployment/SLE_12_SP4/
    - gpgautoimport: True

salt-saphana:
  pkg.installed:
    - fromrepo: saphana
    - require:
      - add-saphana-repo
