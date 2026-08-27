with

    stg_jaffle_shop__customers as (

        select customer_id, first_name, last_name, full_name
        from {{ ref("stg_jaffle_shop__customers") }}

    ),

    stg_jaffle_shop__orders as (

        select customer_id, order_date from {{ ref("stg_jaffle_shop__orders") }}

    ),

    customer_order_dates as (

        select
            customer_id,
            min(order_date) as first_order_date,
            max(order_date) as most_recent_order_date
        from stg_jaffle_shop__orders
        group by customer_id

    ),

    final as (

        select
            stg_jaffle_shop__customers.customer_id,
            stg_jaffle_shop__customers.first_name,
            stg_jaffle_shop__customers.last_name,
            stg_jaffle_shop__customers.full_name,
            customer_order_dates.first_order_date,
            customer_order_dates.most_recent_order_date
        from stg_jaffle_shop__customers
        left join
            customer_order_dates
            on stg_jaffle_shop__customers.customer_id = customer_order_dates.customer_id

    )

select *
from final
