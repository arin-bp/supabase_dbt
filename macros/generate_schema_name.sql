{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- set user_prefix = env_var('DBT_USER_PREFIX', env_var('USER', env_var('USERNAME', ''))) | upper | replace('.', '_') -%}

    {%- if target.name == 'dev' and user_prefix != '' -%}
        {# ONLY IN DEV FOR INDIVIDUAL DEVELOPERS: Add user prefix (e.g. PUBLIC_ARIN) #}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}_{{ user_prefix }}
        {%- else -%}
            {{ custom_schema_name | trim }}_{{ user_prefix }}
        {%- endif -%}

    {%- else -%}
        {# FOR PROD, SIT, UAT, AND CI/CD DEPLOYMENTS: ALWAYS USE CLEAN PUBLIC SCHEMA #}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}
    {%- endif -%}

{%- endmacro %}
