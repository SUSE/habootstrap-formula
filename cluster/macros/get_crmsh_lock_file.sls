{% macro get_crmsh_lock_file() -%}
`python3 -c 'from crmsh import lock; print(lock.Lock.LOCK_DIR)'`
{%- endmacro %}
