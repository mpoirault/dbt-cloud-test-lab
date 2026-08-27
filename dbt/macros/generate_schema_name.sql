{#
  schema routing per target. custom_schema_name is the +schema value from
  dbt_project.yml (raw / staging / intermediate / marts), the prod dataset
  for a stage is always cloud_<stage>.

  - prod: cloud_<stage>                       e.g. cloud_marts
  - ci:   everything goes into target.schema as is. on a PR that is dbt
    Clouds temporary dbt_cloud_pr_<job>_<pr> schema, and keeping all models
    in that one dataset is what lets dbt Cloud drop it when the PR closes
    (suffixed schemas would just linger).
  - dev (anything else): <target.schema>_cloud_<stage>, e.g. dbt_mpoirault_cloud_marts
  - raw is shared: seeds and snapshots build into cloud_raw in every target
    and all targets read sources from there. exception is ci, its snapshots
    stay in the PR schema too, ci must never write to shared raw.
  - no +schema set: falls back to target.schema.

  target.schema is your dev credentials dataset from dbt Cloud, set it to
  dbt_<yourname> (see README). the prod environment has to use target name
  "prod" and the CI job "ci", this macro keys on those.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if custom_schema_name is none or target.name == "ci" -%} {{ target.schema }}
    {%- else -%}
        {%- set prod_schema = "cloud_" ~ custom_schema_name | trim -%}
        {%- if target.name == "prod" or custom_schema_name | trim == "raw" -%}
            {{ prod_schema }}
        {%- else -%} {{ target.schema }}_{{ prod_schema }}
        {%- endif -%}
    {%- endif -%}

{%- endmacro %}
