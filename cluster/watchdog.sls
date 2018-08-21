cluster_watchdog:
  kmod.present:
    - name: softdog
    - persist: True
