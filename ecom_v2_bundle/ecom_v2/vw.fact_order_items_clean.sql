
CREATE VIEW [dbo].[vw_fact_order_items_clean] AS
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
