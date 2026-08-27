with

    raw_payments as (

        select _batched_at, id, orderid, created, paymentmethod, status, amount
        from {{ source("jaffle_shop", "raw_payments") }}

    ),

    renamed as (

        select
            cast(_batched_at as timestamp) as _batched_at,
            cast(id as string) as payment_id,
            cast(orderid as string) as order_id,
            cast(created as date) as payment_date,
            lower(paymentmethod) as payment_method,
            lower(status) as payment_status,
            -- source amounts are in cents
            cast(amount as numeric) / 100 as amount_usd
        from raw_payments

    )

select *
from renamed
