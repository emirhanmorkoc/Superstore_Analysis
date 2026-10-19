-- =========================================================
-- MART SANITY CHECKS
-- Purpose: Validate row counts, value parity, foreign keys, returns mapping, shipping logic, and product consistency checks in the mart layer.
-- Notes: Run after the mart build and before creating analysis views. Includes a check for product_id values linked to multiple product_name values in staging.
-- =========================================================

SELECT
    'row_count_parity' AS check_name,
    stg_cnt,
    mart_cnt,
    mart_cnt - stg_cnt AS diff
FROM (
    SELECT COUNT(*) AS stg_cnt
    FROM stg.orders
) s
CROSS JOIN (
    SELECT COUNT(*) AS mart_cnt
    FROM mart.fact_sales
) f;


SELECT
    'sales_parity' AS check_name,
    ROUND(stg_sales::numeric, 2) AS stg_sales,
    ROUND(mart_sales::numeric, 2) AS mart_sales,
    ROUND((mart_sales - stg_sales)::numeric, 2) AS diff
FROM (
    SELECT COALESCE(SUM(sales), 0) AS stg_sales
    FROM stg.orders
) s
CROSS JOIN (
    SELECT COALESCE(SUM(sales), 0) AS mart_sales
    FROM mart.fact_sales
) f;


SELECT
    'profit_parity' AS check_name,
    ROUND(stg_profit::numeric, 2) AS stg_profit,
    ROUND(mart_profit::numeric, 2) AS mart_profit,
    ROUND((mart_profit - stg_profit)::numeric, 2) AS diff
FROM (
    SELECT COALESCE(SUM(profit), 0) AS stg_profit
    FROM stg.orders
) s
CROSS JOIN (
    SELECT COALESCE(SUM(profit), 0) AS mart_profit
    FROM mart.fact_sales
) f;


SELECT
    'null_fk_check' AS check_name,
    SUM(CASE WHEN order_date_key IS NULL THEN 1 ELSE 0 END) AS null_order_date_key,
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS null_customer_key,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_product_key,
    SUM(CASE WHEN geo_key IS NULL THEN 1 ELSE 0 END) AS null_geo_key,
    SUM(CASE WHEN ship_mode_key IS NULL THEN 1 ELSE 0 END) AS null_ship_mode_key
FROM mart.fact_sales;


SELECT
    'orphan_date_keys' AS check_name,
    COUNT(*) AS orphan_cnt
FROM mart.fact_sales f
LEFT JOIN mart.dim_date d
    ON f.order_date_key = d.date_key
WHERE d.date_key IS NULL

UNION ALL

SELECT
    'orphan_customer_keys' AS check_name,
    COUNT(*) AS orphan_cnt
FROM mart.fact_sales f
LEFT JOIN mart.dim_customer c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL

UNION ALL

SELECT
    'orphan_product_keys' AS check_name,
    COUNT(*) AS orphan_cnt
FROM mart.fact_sales f
LEFT JOIN mart.dim_product p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL

UNION ALL

SELECT
    'orphan_geo_keys' AS check_name,
    COUNT(*) AS orphan_cnt
FROM mart.fact_sales f
LEFT JOIN mart.dim_geo g
    ON f.geo_key = g.geo_key
WHERE g.geo_key IS NULL

UNION ALL

SELECT
    'orphan_ship_mode_keys' AS check_name,
    COUNT(*) AS orphan_cnt
FROM mart.fact_sales f
LEFT JOIN mart.dim_ship_mode sm
    ON f.ship_mode_key = sm.ship_mode_key
WHERE sm.ship_mode_key IS NULL;


SELECT
    'returns_parity' AS check_name,
    raw_returns_orders,
    mart_returned_orders,
    mart_returned_orders - raw_returns_orders AS diff
FROM (
    SELECT COUNT(DISTINCT order_id) AS raw_returns_orders
    FROM raw.returns
) r
CROSS JOIN (
    SELECT COUNT(DISTINCT order_id) AS mart_returned_orders
    FROM mart.fact_sales
    WHERE is_returned = TRUE
) f;


SELECT
    'returned_line_check' AS check_name,
    COUNT(*) AS returned_lines
FROM mart.fact_sales
WHERE is_returned = TRUE;


SELECT
    'days_to_ship_anomalies' AS check_name,
    SUM(CASE WHEN days_to_ship IS NULL THEN 1 ELSE 0 END) AS null_days_to_ship,
    SUM(CASE WHEN days_to_ship < 0 THEN 1 ELSE 0 END) AS negative_days_to_ship,
    MIN(days_to_ship) AS min_days_to_ship,
    MAX(days_to_ship) AS max_days_to_ship
FROM mart.fact_sales;

SELECT
    'product_id_name_consistency' AS check_name,
    COUNT(*) AS affected_product_ids
FROM (
    SELECT product_id
    FROM stg.orders
    GROUP BY product_id
    HAVING COUNT(DISTINCT product_name) > 1
) t;

SELECT
    product_id,
    COUNT(DISTINCT product_name) AS distinct_product_names
FROM stg.orders
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1
ORDER BY distinct_product_names DESC, product_id;