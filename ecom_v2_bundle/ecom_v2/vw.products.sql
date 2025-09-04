
create view [dbo].[vw_dim_products] AS
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
