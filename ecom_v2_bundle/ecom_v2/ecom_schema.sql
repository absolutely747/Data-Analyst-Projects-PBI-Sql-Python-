
-- E-commerce schema (SQL Server/Azure SQL) - raw landing tables
CREATE TABLE dbo.raw_customers (
  customer_id INT,
  first_name NVARCHAR(100),
  last_name  NVARCHAR(100),
  email NVARCHAR(255),
  region NVARCHAR(50),
  join_date DATETIME2,
  updated_at DATETIME2
);
CREATE TABLE dbo.raw_vendors (
  vendor_id INT PRIMARY KEY,
  vendor_name NVARCHAR(200),
  country NVARCHAR(10)
);
CREATE TABLE dbo.raw_products (
  product_id INT PRIMARY KEY,
  product_name NVARCHAR(200),
  category NVARCHAR(100),
  subcategory NVARCHAR(100),
  vendor_id INT
);
CREATE TABLE dbo.raw_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date NVARCHAR(50), -- messy formats by design
  shipping_region NVARCHAR(50)
);
CREATE TABLE dbo.raw_order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price DECIMAL(18,2),
  discount   DECIMAL(18,2),
  tax        DECIMAL(18,2)
);
CREATE TABLE dbo.raw_returns (
  order_item_id INT,
  order_id INT,
  product_id INT,
  qty INT,
  refund_amount DECIMAL(18,2),
  reason NVARCHAR(100),
  order_date DATETIME2,
  return_date DATETIME2,
  refund_processed_at DATETIME2
);
