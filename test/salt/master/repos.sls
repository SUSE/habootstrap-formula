add-shap-factory-repo:
  pkgrepo.managed:
    - name: shap-factory-repo
    - baseurl: https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_12_SP4/
    - gpgautoimport: True

salt-shaptools:
  pkg.installed:
    - fromrepo: shap-factory-repo
    - require:
      - add-shap-factory-repo
