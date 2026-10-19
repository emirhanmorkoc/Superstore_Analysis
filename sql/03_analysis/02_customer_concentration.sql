-- =========================================================
-- ANALYSIS VIEW: CUSTOMER CONCENTRATION
-- Purpose: Aggregate sales and profit by customer and segment for concentration analysis, top-customer ranking, and customer scatter visuals.
-- Grain: One row per customer.
-- =========================================================

CREATE OR REPLACE VIEW mart.vw_02_customer_concentration AS
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    SUM(s.sales) AS sales_total,
    SUM(s.profit) AS profit_total
FROM mart.fact_sales s
JOIN mart.dim_customer c
    ON s.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.customer_name,
    c.segment;