with

    snp_customers as (

        select id, first_name, last_name, dbt_valid_to from {{ ref("snp_customers") }}

    ),

    current_customers as (

        select
            cast(id as string) as customer_id,
            first_name,
            last_name,
            concat(first_name, ' ', last_name) as full_name
        from snp_customers
        where dbt_valid_to is null

    )

select *
from
    current_customers

    -- ci wiring probe after repo migration, safe to keep
