-- =========================================================
-- ANALYSIS VIEW: RETURNS HOTSPOTS
-- Purpose: Summarize product-level return exposure for return-value ranking and profit leakage analysis in Power BI.
-- Grain: One row per product_name within category/subcategory.
-- Notes: profit_on_returned_lines_proxy is an exposure proxy, not a true net profit metric.
-- =========================================================

CREATE OR REPLACE VIEW mart.vw_04_returns_hotspots AS
SELECT
    p.category,
    p.sub_category,
    p.product_name,
    COUNT(*) AS order_lines_cnt,
    SUM(CASE WHEN s.is_returned THEN 1 ELSE 0 END) AS returned_lines_cnt,
    SUM(s.sales) AS sales_total,
    SUM(CASE WHEN s.is_returned THEN s.sales ELSE 0 END) AS returned_sales_total,
    SUM(CASE WHEN s.is_returned THEN s.profit ELSE 0 END) AS profit_on_returned_lines_proxy
FROM mart.fact_sales s
JOIN mart.dim_product p
    ON s.product_key = p.product_key
GROUP BY
    p.category,
    p.sub_category,
    p.product_name;