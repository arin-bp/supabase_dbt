{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {# Get Snowflake session username #}
    {%- set sf_user = env_var('DBT_USER_PREFIX', target.user) | upper | replace('.', '_') | replace('-', '_') -%}

    {%- if target.name in ['dev', 'sit', 'uat'] and not sf_user.startswith('SVC_') -%}
        {# DEV, SIT, UAT for Human Users: Append User Prefix (e.g. PUBLIC_ARIN_DHIMAR) #}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}_{{ sf_user }}
        {%- else -%}
            {{ custom_schema_name | trim }}_{{ sf_user }}
        {%- endif -%}

    {%- else -%}
        {# PROD (and Service Accounts in DEV/SIT/UAT): ALWAYS Clean PUBLIC Schema #}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}
    {%- endif -%}

{%- endmacro %}
