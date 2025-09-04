/*select count(*) from dbo.raw_customers;

select count(*) from dbo.raw_products;

select count(*) from dbo.raw_returns;


select count(*) from dbo.raw_vendors;

select count(*) from dbo.raw_orders;


select count(*) from dbo.raw_order_items_part1;

select * from raw_orders;


select * from raw_order_items_part1;
select count(*) from raw_order_items_part6;

select * from raw_orders;


IF OBJECT_ID('dbo.raw_order_items','U') IS NULL
BEGIN
    CREATE TABLE dbo.raw_order_items (
        order_item_id INT            NOT NULL,
        order_id      INT            NOT NULL,
        product_id    INT            NOT NULL,
        quantity      INT            NOT NULL,
        unit_price    DECIMAL(18,2)  NOT NULL,
        discount      DECIMAL(18,2)  NOT NULL,
        tax           DECIMAL(18,2)  NOT NULL,
        CONSTRAINT PK_raw_order_items PRIMARY KEY (order_item_id)
    );
END
GO


SET XACT_ABORT ON;
BEGIN TRAN;

-- Ensure final table exists (safe-guard)
IF OBJECT_ID('dbo.raw_order_items','U') IS NULL
BEGIN
    CREATE TABLE dbo.raw_order_items (
        order_item_id INT            NOT NULL,
        order_id      INT            NOT NULL,
        product_id    INT            NOT NULL,
        quantity      INT            NOT NULL,
        unit_price    DECIMAL(18,2)  NOT NULL,
        discount      DECIMAL(18,2)  NOT NULL,
        tax           DECIMAL(18,2)  NOT NULL,
        CONSTRAINT PK_raw_order_items PRIMARY KEY (order_item_id)
    );
END;

WITH all_parts AS (
    SELECT order_item_id, order_id, product_id, quantity, unit_price, discount, tax FROM dbo.raw_order_items_part1
    UNION ALL
    SELECT order_item_id, order_id, product_id, quantity, unit_price, discount, tax FROM dbo.raw_order_items_part2
    UNION ALL
    SELECT order_item_id, order_id, product_id, quantity, unit_price, discount, tax FROM dbo.raw_order_items_part3
    UNION ALL
    SELECT order_item_id, order_id, product_id, quantity, unit_price, discount, tax FROM dbo.raw_order_items_part4
    UNION ALL
    SELECT order_item_id, order_id, product_id, quantity, unit_price, discount, tax FROM dbo.raw_order_items_part5
    UNION ALL
    SELECT order_item_id, order_id, product_id, quantity, unit_price, discount, tax FROM dbo.raw_order_items_part6
)
INSERT INTO dbo.raw_order_items (order_item_id, order_id, product_id, quantity, unit_price, discount, tax)
SELECT s.order_item_id, s.order_id, s.product_id, s.quantity, s.unit_price, s.discount, s.tax
FROM all_parts s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.raw_order_items r WHERE r.order_item_id = s.order_item_id
);

COMMIT;

-- Quick checks (optional)
SELECT COUNT(*) AS rows_in_final FROM dbo.raw_order_items;
SELECT order_item_id, COUNT(*) AS dup_count
FROM dbo.raw_order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;



set sql_safE_updates=0;
drop table dbo.raw_order_items_part1;
drop table dbo.raw_order_items_part2;
drop table dbo.raw_order_items_part3;
drop table dbo.raw_order_items_part4;
drop table dbo.raw_order_items_part5
drop table dbo.raw_products;



select top(1000) * from dbo.raw_order_items ;



select count(*) from dbo.raw_customers;

select count(*) from dbo.raw_products;

select count(*) from dbo.raw_returns;


select count(*) from dbo.raw_vendors;

select count(*) from dbo.raw_orders;


-- Row counts for all raw tables
SELECT 'dbo.raw_customers'    AS table_name, COUNT_BIG(*) AS row_count FROM dbo.raw_customers
UNION ALL
SELECT 'dbo.raw_vendors',                   COUNT_BIG(*)  FROM dbo.raw_vendors
UNION ALL
SELECT 'dbo.raw_products',                  COUNT_BIG(*)  FROM dbo.raw_products
UNION ALL
SELECT 'dbo.raw_orders',                    COUNT_BIG(*)  FROM dbo.raw_orders
UNION ALL
SELECT 'dbo.raw_order_items',               COUNT_BIG(*)  FROM dbo.raw_order_items
UNION ALL
SELECT 'dbo.raw_returns',                   COUNT_BIG(*)  FROM dbo.raw_returns
ORDER BY table_name;


select 'dbo.raw_customers' as table_name,
count(*) as count,min(customer_id) as mini,max(customer_id) as maax
from dbo.raw_customers
union all 
select 'dbo.raw_products' as table_name,
count(*) as count,min(product_id) as mini,max(product_id) as maax
from dbo.raw_products
union all 
select 'dbo.raw_ordeR_items' as table_name,
count(*) as count,min(order_item_id) as mini,max(order_item_id) as maax
from dbo.raw_order_items
union all 
select 'dbo.raw_returns' as table_name,
count(*) as count,min(order_item_id) as mini,max(order_item_id) as maax
from dbo.raw_returns
union all 
select 'dbo.raw_vendors' as table_name,
count(*) as count,min(vendor_id) as mini,max(vendor_id) as maax
from dbo.raw_vendors
union all 
select 'dbo.raw_orders' as table_name,
count(*) as count,min(order_id) as mini,max(order_id) as maax
from dbo.raw_orders;



-- How many duplicate keys and duplicate rows per table
WITH c_dup AS (
  SELECT customer_id AS k, COUNT(*) AS cnt FROM dbo.raw_customers GROUP BY customer_id HAVING COUNT(*) > 1
),
v_dup AS (
  SELECT vendor_id   AS k, COUNT(*) AS cnt FROM dbo.raw_vendors   GROUP BY vendor_id   HAVING COUNT(*) > 1
),
p_dup AS (
  SELECT product_id  AS k, COUNT(*) AS cnt FROM dbo.raw_products  GROUP BY product_id  HAVING COUNT(*) > 1
),
o_dup AS (
  SELECT order_id    AS k, COUNT(*) AS cnt FROM dbo.raw_orders    GROUP BY order_id    HAVING COUNT(*) > 1
),
oi_dup AS (
  SELECT order_item_id AS k, COUNT(*) AS cnt FROM dbo.raw_order_items GROUP BY order_item_id HAVING COUNT(*) > 1
),
r_dup AS (
  SELECT order_item_id AS k, COUNT(*) AS cnt FROM dbo.raw_returns GROUP BY order_item_id HAVING COUNT(*) > 1
)
SELECT 'raw_customers'    AS table_name, ISNULL(COUNT(c_dup.k),0) AS dup_keys, ISNULL(SUM(c_dup.cnt-1),0) AS extra_rows_from_dups FROM c_dup
UNION ALL
SELECT 'raw_vendors',                    COUNT(v_dup.k),           ISNULL(SUM(v_dup.cnt-1),0)             FROM v_dup
UNION ALL
SELECT 'raw_products',                   COUNT(p_dup.k),           ISNULL(SUM(p_dup.cnt-1),0)             FROM p_dup
UNION ALL
SELECT 'raw_orders',                     COUNT(o_dup.k),           ISNULL(SUM(o_dup.cnt-1),0)             FROM o_dup
UNION ALL
SELECT 'raw_order_items',                COUNT(oi_dup.k),          ISNULL(SUM(oi_dup.cnt-1),0)            FROM oi_dup
UNION ALL
SELECT 'raw_returns',                    COUNT(r_dup.k),           ISNULL(SUM(r_dup.cnt-1),0)             FROM r_dup
ORDER BY table_name;



SELECT 'raw_customers'    AS table_name, COUNT(*) AS null_keys  FROM dbo.raw_customers   WHERE customer_id   IS NULL
UNION ALL SELECT 'raw_vendors',         COUNT(*)                FROM dbo.raw_vendors     WHERE vendor_id     IS NULL
UNION ALL SELECT 'raw_products',        COUNT(*)                FROM dbo.raw_products    WHERE product_id    IS NULL
UNION ALL SELECT 'raw_orders',          COUNT(*)                FROM dbo.raw_orders      WHERE order_id      IS NULL
UNION ALL SELECT 'raw_order_items',     COUNT(*)                FROM dbo.raw_order_items WHERE order_item_id IS NULL
UNION ALL SELECT 'raw_returns',         COUNT(*)                FROM dbo.raw_returns     WHERE order_item_id IS NULL
ORDER BY table_name;

select top(20) customer_id,count(*) as dup from dbo.raw_customers group by customer_id HAVING count(*)>1
-- 1200 duplicates records means customers are duplicated either with new email id or any new change...

-- adding primary keys to add the tables



IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_raw_order_items')
AND NOT EXISTS (SELECT 1 FROM dbo.raw_order_items GROUP BY order_item_id HAVING COUNT(*) > 1)
BEGIN
  ALTER TABLE dbo.raw_order_items
  ADD CONSTRAINT PK_raw_order_items PRIMARY KEY CLUSTERED (order_item_id);
END
GO


if not EXISTS(select 1 from sys.key_constraints where name='PK_order_id')
and not exists (select 1 from dbo.raw_orders group by order_id having count (*)>1)
begin 
    alter table dbo.raw_orders
    add CONSTRAINT PK_raw_orders PRIMARY KEY CLUSTERED(order_id);
END
go



if not EXISTS(select 1 from sys.key_constraints where name='PK_product_id')
and not EXISTS (select 1 from dbo.raw_products group by product_id having count(*)>1)
BEGIN
    alter table dbo.raw_products 
    add CONSTRAINT PK_raw_products PRIMARY KEY CLUSTERED(product_id);
END
Go

if not EXISTS(select 1 from sys.key_constraints where name='PK_vendor_id')
and not EXISTS (select 1 from dbo.raw_vendors group by vendor_id having count(*)>1)
BEGIN
    alter table dbo.raw_vendors 
    add CONSTRAINT PK_raw_vendors PRIMARY KEY CLUSTERED(vendor_id);
END
Go

if not EXISTS(select 1 from sys.key_constraints where name='PK_product_id')
and not EXISTS (select 1 from dbo.raw_products group by product_id having count(*)>1)
BEGIN
    alter table dbo.raw_products 
    add CONSTRAINT PK_raw_products PRIMARY KEY CLUSTERED(product_id);
END
Go

*/


--- below code is used for checking the records match or else the join will not work they will break
-- SELECT COUNT(*) AS orphans_items_orders
-- FROM dbo.raw_order_items oi
-- LEFT JOIN dbo.raw_orders o ON o.order_id = oi.order_id
-- WHERE o.order_id IS NULL;

-- SELECT COUNT(*) AS orphans_items_products
-- FROM dbo.raw_order_items oi
-- LEFT JOIN dbo.raw_products p ON p.product_id = oi.product_id
-- WHERE p.product_id IS NULL;

-- SELECT COUNT(*) AS orphans_returns_items
-- FROM dbo.raw_returns r
-- LEFT JOIN dbo.raw_order_items oi ON oi.order_item_id = r.order_item_id
-- WHERE oi.order_item_id IS NULL;

-- SELECT TOP (50) oi.*
-- FROM dbo.raw_order_items oi
-- LEFT JOIN dbo.raw_orders o ON o.order_id = oi.order_id
-- WHERE o.order_id IS NULL;


select top(200)*  from raw_order_items;


select 
sum(case when quantity<=0 then 1 else 0 end ) as qty_bad,
sum(case when discount<0 then 1 else 0 end ) as discountbad,
sum(case when tax<0 then 1 else 0 end ) as tax_bad,
sum(case when unit_price <0 then 1 else 0 end) as unit_price_bad
from dbo.raw_order_items;


SELECT shipping_region, COUNT(*) AS rows
FROM dbo.raw_orders
GROUP BY shipping_region
HAVING shipping_region NOT IN ('APAC','EMEA','AMER','LATAM');


SELECT COUNT(*) AS extreme_discounts
FROM dbo.raw_order_items
WHERE discount / NULLIF(unit_price*quantity + discount,0) > 0.90;



SELECT
  SUM(CASE WHEN return_date < order_date THEN 1 ELSE 0 END)        AS bad_return_before_order,
  SUM(CASE WHEN refund_processed_at < return_date THEN 1 ELSE 0 END) AS bad_refund_before_return
FROM dbo.raw_returns;


create index ix_raw_order_items_order_id on dbo.raw_ordeR_items(order_id)
-- we are creating index on the above table raW_order_items and on order_id because it will help to join ordeR_id table faster with ordeR_items table 
-- its kind of creating an index with child table



select top(1000)* from dbo.raw_orders;

-- Parse messy NVARCHAR order_date into a proper DATE
CREATE OR ALTER VIEW dbo.vw_orders_clean AS
SELECT
  o.order_id,
  o.customer_id,
  -- try common formats: 23=yyyy-mm-dd, 120=yyyy-mm-dd hh:mi:ss, 103=dd/mm/yyyy, 105=dd-mm-yyyy
  COALESCE(
    TRY_CONVERT(date, o.order_date, 23),
    TRY_CONVERT(date, o.order_date, 120),
    TRY_CONVERT(date, o.order_date, 103),
    TRY_CONVERT(date, o.order_date, 105),
    TRY_CONVERT(date, o.order_date)          -- last-resort generic
  ) AS order_day,
  o.shipping_region
FROM dbo.raw_orders o;


select * from dbo.vw_orders_clean;

select count(*) from dbo.vw_orders_clean where order_day is null;

EXEC sp_help 'dbo.vw_orders_clean';


select * from dbo.raw_customers;

create view dbo.vw_dim_customer as 
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

select * from dbo.vw_dim_customer;





select top(1000)* from dbo.raw_products;


create view dbo.vw_dim_products AS
select 
    p.product_id,
    LTRIM(RTRIM(p.product_name)) as product_name,
    case when LTRIM(RTRIM(p.category)) is null or LTRIM(RTRIM(p.category)) =NULLIF(' ',0) then 'Unknown'
    else LOWER(LTRIM(RTRIM(p.category))) end as category,
    LTRIM(RTRIM(p.subcategory)) as subcategory,
    v.vendor_id,
    v.vendor_name,
    v.country as vendor_country
    from dbo.raw_products p
    left join dbo.raw_vendors v
    on p.vendor_id=v.vendor_id;
GO


select top(200)* from dbo.vw_dim_products;

select count(*) as orphan_products
from dbo.raw_products p 
left join dbo.raw_vendors v on p.vendor_id=v.vendor_id
where v.vendor_id is null;


SELECT COUNT(*) AS null_or_blank_categories
FROM dbo.raw_products
WHERE category IS NULL
   OR LTRIM(RTRIM(category)) = '';

SELECT COUNT(*) AS null_or_blank_categories
FROM dbo.raw_products
WHERE category IS NULL
OR LTRIM(RTRIM(category)) = '';


/* 3) Order items — normalized amounts + clean order date */
CREATE VIEW dbo.vw_fact_order_items_clean AS
SELECT
  oi.order_item_id,
  oi.order_id,
  oc.order_day,                 
  oc.customer_id,
  oc.shipping_region,
  oi.product_id,
  oi.quantity,
  oi.unit_price,
  oi.discount,
  oi.tax,
  -- normalized amounts
  ABS(oi.discount) AS discount_amount,
  CASE WHEN oi.discount < 0
       THEN (oi.unit_price * oi.quantity) + oi.discount   -- discount stored negative (off the list)
       ELSE (oi.unit_price * oi.quantity)                  -- unit_price already net of discount
  END AS net_sales,
  CASE WHEN oi.discount < 0
       THEN (oi.unit_price * oi.quantity)                  -- list was unit_price*qty
       ELSE (oi.unit_price * oi.quantity) + oi.discount
  END AS list_amount,
  CASE WHEN oi.discount < 0
       THEN (oi.unit_price * oi.quantity) + oi.discount + oi.tax
       ELSE (oi.unit_price * oi.quantity) + oi.tax
  END AS net_with_tax
FROM dbo.raw_order_items oi
JOIN dbo.vw_orders_clean oc
  ON oc.order_id = oi.order_id
WHERE oc.order_day IS NOT NULL;   -- keep only parsable dates
GO


select * from dbo.vw_fact_order_items_clean;


select top(100)* from dbo.raw_returns;


create view dbo.vw_returns_clean  AS
select 
order_item_id,
order_id,
product_id,
qty as qty_returned,
refund_amount,
CASE WHEN NULLIF(LTRIM(RTRIM(reason)),'') IS NULL THEN 'Unknown'
ELSE LTRIM(RTRIM(reason)) END AS reason,
CAST(return_date AS date) AS return_day,
case when order_date<=return_date  THEN DATEDIFF(DAY, CAST(order_date AS date), CAST(return_date AS date)) end as days_to_return,
case when return_date<=refund_processed_at THEN DATEDIFF(DAY, CAST(return_date AS date), CAST(refund_processed_at AS date)) end as days_to_refund
from dbo.raw_returns;



select top(100)* from dbo.vw_returns_clean;



CREATE VIEW dbo.vw_fact_order_items_clean AS
SELECT
  oi.order_item_id,
  oi.order_id,
  oc.order_day,                 
  oc.customer_id,
  oc.shipping_region,
  oi.product_id,
  oi.quantity,
  oi.unit_price,
  oi.discount,
  oi.tax,
  -- normalized amounts
  ABS(oi.discount) AS discount_amount,
  CASE WHEN oi.discount < 0
       THEN (oi.unit_price * oi.quantity) + oi.discount   -- discount stored negative (off the list)
       ELSE (oi.unit_price * oi.quantity)                  -- unit_price already net of discount
  END AS net_sales,
  CASE WHEN oi.discount < 0
       THEN (oi.unit_price * oi.quantity)                  -- list was unit_price*qty
       ELSE (oi.unit_price * oi.quantity) + oi.discount
  END AS list_amount,
  CASE WHEN oi.discount < 0
       THEN (oi.unit_price * oi.quantity) + oi.discount + oi.tax
       ELSE (oi.unit_price * oi.quantity) + oi.tax
  END AS net_with_tax
FROM dbo.raw_order_items oi
JOIN dbo.vw_orders_clean oc
  ON oc.order_id = oi.order_id
WHERE oc.order_day IS NOT NULL;   -- keep only parsable dates
GO


CREATE TABLE dbo.Security_UserRegion (
  UPN     nvarchar(255) NOT NULL,   -- user's login email or AAD group address
  Region  nvarchar(100) NOT NULL    -- must match DimCustomers[Region]: APAC/AMER/EMEA/LATAM
);

-- Examples (user → 1+ regions)
INSERT INTO dbo.Security_UserRegion (UPN, Region) VALUES
('apac.analyst@yourco.com','APAC'),
('amer.analyst@yourco.com','AMER'),
('global.manager@yourco.com','APAC'),
('global.manager@yourco.com','EMEA');