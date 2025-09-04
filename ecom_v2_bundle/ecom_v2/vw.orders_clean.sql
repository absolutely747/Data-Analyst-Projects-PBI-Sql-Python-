
CREATE   VIEW [dbo].[vw_orders_clean] AS
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
GO
