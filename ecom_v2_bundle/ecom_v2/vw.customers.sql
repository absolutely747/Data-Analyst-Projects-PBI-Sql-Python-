
create view [dbo].[vw_dim_customer] as 
with ranked as
(
    select 
    customer_id,
    LTRIM(RTRIM(first_name)) as first_name,
    LTRIM(RTRIM(last_name)) as last_name,
    lower(LTRIM(RTRIM(email))) as email,
    LTRIM(RTRIM(region)) as region,
    join_date,
    updated_at,
    row_number() over (PARTITION by customer_id order by updated_at desc,join_date desc,customer_id) as rn
    from dbo.raw_customers
)
select customer_id as customer_key,first_name,last_name,email,region,join_date,updated_at,CONCAT(first_name,' ',last_name) as full_name
from ranked where rn=1;
GO



