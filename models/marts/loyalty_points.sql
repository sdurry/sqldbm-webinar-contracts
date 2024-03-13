with cust as (

    select
        customer_id,        
        name,               
        address,            
        location_id,        
        phone,              
        account_balance_usd,
        market_segment,    
        comment            
    from {{ ref('stg_customer') }}

)

, ord as (

  select 
        sales_order_id,
        customer_id,   
        order_status,  
        total_price_usd,
        order_date,    
        order_priority,
        clerk,         
        ship_priority,
        comment       
   from {{ ref('stg_sales_order') }}
)

, cust_ord as ( 

    select c.customer_id, sum(total_price_usd) as total_price_usd 
            from ord o 
            inner join cust c 
            on o.customer_id = c.customer_id
            where true 
            group by 1

)

, business_logic as (
select 
  customer_id
, case when total_price_usd >= 3500000 then 'gold'
       when total_price_usd between 2000000 and 3499999 then 'silver'
       else 'bronze'
   end as medallion_level
,  round(total_price_usd / 10000) as points_amount

   from cust_ord 
)

select * from business_logic
