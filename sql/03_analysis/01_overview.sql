-- =========================================================
-- ANALYSIS VIEW: OVERVIEW
-- Purpose: Provide a thin reporting view for overview KPIs, monthly trend, subcategory scatter, and geography analysis in Power BI.
-- Grain: One row per order line.
-- =========================================================

CREATE OR REPLACE VIEW mart.vw_01_overview AS
SELECT
    date_trunc('month', d.date_value)::date AS month_start,
    s.order_id,
    g.state,
    g.city,
    p.category,
    p.sub_category,
    s.sales,
    s.profit
FROM mart.fact_sales s
JOIN mart.dim_date d
    ON s.order_date_key = d.date_key
JOIN mart.dim_geo g
    ON s.geo_key = g.geo_key
JOIN mart.dim_product p
    ON s.product_key = p.product_key;