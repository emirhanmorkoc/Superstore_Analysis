-- =========================================================
-- RAW SANITY CHECKS
-- Purpose: Validate row counts, missing values, duplicates, and parse readiness.
-- Notes: Run after loading raw tables and before staging inserts.
-- =========================================================

SELECT table_name, n
FROM (
  SELECT 'raw.orders'  AS table_name, COUNT(*) AS n FROM raw.orders
  UNION ALL
  SELECT 'raw.returns' AS table_name, COUNT(*) AS n FROM raw.returns
) s
ORDER BY table_name;


SELECT
  COUNT(*) FILTER (WHERE NULLIF(TRIM(row_id),      '') IS NULL) AS row_id_missing,
  COUNT(*) FILTER (WHERE NULLIF(TRIM(order_id),    '') IS NULL) AS order_id_missing,
  COUNT(*) FILTER (WHERE NULLIF(TRIM(customer_id), '') IS NULL) AS customer_id_missing,
  COUNT(*) FILTER (WHERE NULLIF(TRIM(product_id),  '') IS NULL) AS product_id_missing
FROM raw.orders;


SELECT row_id, COUNT(*) AS cnt
FROM raw.orders
GROUP BY row_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC;


SELECT order_id, COUNT(*) AS line_cnt
FROM raw.orders
GROUP BY order_id
ORDER BY line_cnt DESC
LIMIT 20;


SELECT
  MIN(to_date(TRIM(order_date), 'DD.MM.YYYY')) AS min_order_date,
  MAX(to_date(TRIM(order_date), 'DD.MM.YYYY')) AS max_order_date,
  MIN(to_date(TRIM(ship_date),  'DD.MM.YYYY')) AS min_ship_date,
  MAX(to_date(TRIM(ship_date),  'DD.MM.YYYY')) AS max_ship_date
FROM raw.orders;


SELECT
  MIN(NULLIF(REPLACE(TRIM(sales),    ',', '.'), '')::numeric) AS min_sales,
  MAX(NULLIF(REPLACE(TRIM(sales),    ',', '.'), '')::numeric) AS max_sales,
  MIN(NULLIF(REPLACE(TRIM(discount), ',', '.'), '')::numeric) AS min_discount,
  MAX(NULLIF(REPLACE(TRIM(discount), ',', '.'), '')::numeric) AS max_discount,
  MIN(NULLIF(REPLACE(TRIM(profit),   ',', '.'), '')::numeric) AS min_profit,
  MAX(NULLIF(REPLACE(TRIM(profit),   ',', '.'), '')::numeric) AS max_profit
FROM raw.orders;


SELECT
  COUNT(*) AS returns_rows,
  COUNT(*) FILTER (WHERE o.order_id IS NOT NULL) AS returns_matched_in_orders,
  COUNT(*) FILTER (WHERE o.order_id IS NULL)     AS returns_missing_in_orders
FROM (
  SELECT NULLIF(TRIM(order_id), '') AS order_id
  FROM raw.returns
) r
LEFT JOIN (
  SELECT DISTINCT NULLIF(TRIM(order_id), '') AS order_id
  FROM raw.orders
) o
  ON o.order_id = r.order_id;