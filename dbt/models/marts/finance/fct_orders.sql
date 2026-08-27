with

    stg_jaffle_shop__orders as (

        select order_id, customer_id, order_date, order_status
        from {{ ref("stg_jaffle_shop__orders") }}

    ),

    int_finance__payments_pivot as (

        select
            order_id,
            credit_card_amount_usd,
            coupon_amount_usd,
            bank_transfer_amount_usd,
            gift_card_amount_usd,
            total_amount_usd
        from {{ ref("int_finance__payments_pivot") }}

    ),

    final as (

        select
            stg_jaffle_shop__orders.order_id,
            stg_jaffle_shop__orders.customer_id,
            stg_jaffle_shop__orders.order_date,
            stg_jaffle_shop__orders.order_status,
            coalesce(
                int_finance__payments_pivot.credit_card_amount_usd, 0
            ) as credit_card_amount_usd,
            coalesce(
                int_finance__payments_pivot.coupon_amount_usd, 0
            ) as coupon_amount_usd,
            coalesce(
                int_finance__payments_pivot.bank_transfer_amount_usd, 0
            ) as bank_transfer_amount_usd,
            coalesce(
                int_finance__payments_pivot.gift_card_amount_usd, 0
            ) as gift_card_amount_usd,
            coalesce(
                int_finance__payments_pivot.total_amount_usd, 0
            ) as total_amount_usd
        from stg_jaffle_shop__orders
        left join
            int_finance__payments_pivot
            on stg_jaffle_shop__orders.order_id = int_finance__payments_pivot.order_id

    )

select *
from final
