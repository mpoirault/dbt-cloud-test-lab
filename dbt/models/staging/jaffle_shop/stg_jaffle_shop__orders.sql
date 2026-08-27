with

    raw_orders as (

        select _etl_loaded_at, id, user_id, order_date, status
        from {{ source("jaffle_shop", "raw_orders") }}

    ),

    renamed as (

        select
            cast(_etl_loaded_at as timestamp) as _loaded_at,
            cast(id as string) as order_id,
            cast(user_id as string) as customer_id,
            cast(order_date as date) as order_date,
            lower(status) as order_status
        from raw_orders

    )

select *
from renamed
