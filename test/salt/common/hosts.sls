master:
  host.present:
    - ip: 10.13.38.11

{% for idx in 1, 2, 3 %}
node{{ idx }}:
  host.present:
    - ip: 10.13.38.{{ idx + 11 }}
{% endfor %}
