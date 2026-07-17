{% macro load_csv(file_path, target_table) %}
    
    {% set copy_query %}
        COPY public.{{ target_table }}
        FROM '{{ file_path }}'
        DELIMITER ','
        CSV HEADER;
    {% endset %}

    {% do log("Executing COPY from " ~ file_path ~ " into existing table: " ~ target_table, info=True) %}
    {% do run_query(copy_query) %}
    
    {% do log("Successfully appended CSV data into " ~ target_table, info=True) %}

{% endmacro %}
