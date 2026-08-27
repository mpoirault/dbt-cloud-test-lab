with

    dim_date as (select date_day from {{ ref("dim_date") }}),

    fct_orders as (select order_date, total_amount_usd from {{ ref("fct_orders") }}),

    daily_orders as (

        select order_date, count(*) as order_count, sum(total_amount_usd) as revenue_usd
        from fct_orders
        group by order_date

    ),

    final as (

        select
            dim_date.date_day,
            coalesce(daily_orders.order_count, 0) as order_count,
            coalesce(daily_orders.revenue_usd, 0) as revenue_usd
        from dim_date
        left join daily_orders on dim_date.date_day = daily_orders.order_date

    )

select *
from final
