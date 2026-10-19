-- =========================================================
-- ANALYSIS VIEW: DISCOUNTS VS PROFIT
-- Purpose: Summarize sales and profit by discount bucket and product hierarchy to evaluate margin erosion and discount exposure.
-- Grain: One row per discount bucket and category/subcategory combination.
-- =========================================================

CREATE OR REPLACE VIEW mart.vw_05_discounts_vs_profit AS
WITH bucketed AS (
    SELECT
        p.category,
        p.sub_category,
        s.sales,
        s.profit,
        CASE
            WHEN s.discount = 0 THEN '0%'
            WHEN s.discount > 0 AND s.discount <= 0.10 THEN '0-10%'
            WHEN s.discount > 0.10 AND s.discount <= 0.20 THEN '10-20%'
            WHEN s.discount > 0.20 AND s.discount <= 0.30 THEN '20-30%'
            WHEN s.discount > 0.30 AND s.discount <= 0.50 THEN '30-50%'
            ELSE '50%+'
        END AS discount_bucket,
        CASE
            WHEN s.discount = 0 THEN 1
            WHEN s.discount > 0 AND s.discount <= 0.10 THEN 2
            WHEN s.discount > 0.10 AND s.discount <= 0.20 THEN 3
            WHEN s.discount > 0.20 AND s.discount <= 0.30 THEN 4
            WHEN s.discount > 0.30 AND s.discount <= 0.50 THEN 5
            ELSE 6
        END AS bucket_sort
    FROM mart.fact_sales s
    JOIN mart.dim_product p
        ON s.product_key = p.product_key
)
SELECT
    category,
    sub_category,
    bucket_sort,
    discount_bucket,
    SUM(sales) AS sales_total,
    SUM(profit) AS profit_total
FROM bucketed
GROUP BY
    category,
    sub_category,
    bucket_sort,
    discount_bucket;