
create view [dbo].[vw_returns_clean]  AS
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
GO
