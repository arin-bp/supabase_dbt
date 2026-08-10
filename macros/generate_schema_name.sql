{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- set sf_user = env_var('DBT_USER_PREFIX', target.user) | upper | replace('.', '_') | replace('-', '_') -%}

    {%- if target.name in ['dev', 'sit', 'uat'] and not sf_user.startswith('SVC_') -%}

        {%- if custom_schema_name is none -%}
            {{ default_schema }}_{{ sf_user }}

        {%- elif custom_schema_name | lower | trim in ['raw'] -%}
            {{ custom_schema_name | trim }}

        {%- else -%}
            {{ custom_schema_name | trim }}_{{ sf_user }}
        {%- endif -%}

    {%- else -%}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}
    {%- endif -%}

{%- endmacro %}
