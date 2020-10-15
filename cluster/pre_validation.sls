{% from "cluster/map.jinja" import cluster with context -%}

{% if cluster.configure_checkbox is defined %}
  {% if cluster.configure.configure_url_checkbox is sameas true %}
    {% do cluster.configure.pop('template', none) %}
  {% else %}
    {% do cluster.configure.pop('url', none) %}
    {% if cluster.configure.template.parameters is defined and cluster.configure.template.parameters|length > 0 %}
      {% set new_parameters = {} %}
      {% for new_item in cluster.configure.template.parameters %}
        {% do new_parameters.update({new_item.key: new_item.value}) %}
      {% endfor %}
      {% do cluster.configure.template.update({'parameters': new_parameters}) %}
    {% endif %}
  {% endif %}
{% endif %}

{% if cluster.sbd is defined and cluster.sbd_checkbox is defined %}
{% if cluster.sbd.diskless_checkbox is defined and cluster.sbd.diskless_checkbox is sameas true %}
{% do cluster.sbd.update({'device': false}) %}
{% endif %}
{% endif %}


{% if cluster.sbd.configure_sbd_checkbox is not defined or cluster.sbd.configure_sbd_checkbox is sameas false %}
{% do cluster.sbd.pop('configure_resource', none) %}
{% endif %}
