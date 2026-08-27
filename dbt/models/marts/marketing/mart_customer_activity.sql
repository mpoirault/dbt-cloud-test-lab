with

    dim_customers as (

        select customer_id, full_name, first_order_date, most_recent_order_date
        from {{ ref("dim_customers") }}

    ),

    fct_orders as (select customer_id, total_amount_usd from {{ ref("fct_orders") }}),

    customer_orders as (

        select
            customer_id,
            count(*) as order_count,
            sum(total_amount_usd) as lifetime_value_usd,
            avg(total_amount_usd) as average_order_value_usd
        from fct_orders
        group by customer_id

    ),

    final as (

        select
            dim_customers.customer_id,
            dim_customers.full_name,
            dim_customers.first_order_date,
            dim_customers.most_recent_order_date,
            coalesce(customer_orders.order_count, 0) as order_count,
            coalesce(customer_orders.lifetime_value_usd, 0) as lifetime_value_usd,
            customer_orders.average_order_value_usd
        from dim_customers
        left join
            customer_orders on dim_customers.customer_id = customer_orders.customer_id

    )

select *
from final
