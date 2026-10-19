-- =========================================================
-- ANALYSIS VIEW: PRODUCT PORTFOLIO
-- Purpose: Aggregate sales and profit by product for product ranking, profitability distribution, and category/subcategory drill-down analysis.
-- Grain: One row per product_id + product_name + category + sub_category combination.
-- =========================================================

CREATE OR REPLACE VIEW mart.vw_03_product_portfolio AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    SUM(s.sales) AS sales_total,
    SUM(s.profit) AS profit_total
FROM mart.fact_sales s
JOIN mart.dim_product p
    ON s.product_key = p.product_key
GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category;