-- =========================================================
-- STAGING SANITY CHECKS
-- Purpose: Validate typed data after raw-to-staging transformation.
-- Notes: Focus on nulls, duplicates, ranges, and key readiness for mart loading.
-- =========================================================

SELECT src, n
FROM (
  SELECT 'raw.orders' AS src, COUNT(*) AS n FROM raw.orders
  UNION ALL
  SELECT 'stg.orders' AS src, COUNT(*) AS n FROM stg.orders
  UNION ALL
  SELECT 'raw.returns' AS src, COUNT(*) AS n FROM raw.returns
  UNION ALL
  SELECT 'stg.returns' AS src, COUNT(*) AS n FROM stg.returns
) s
ORDER BY src;


SELECT
  COUNT(*) AS returns_rows,
  COUNT(*) FILTER (WHERE o.order_id IS NOT NULL) AS returns_matched_in_orders,
  COUNT(*) FILTER (WHERE o.order_id IS NULL)     AS returns_missing_in_orders
FROM stg.returns r
LEFT JOIN (SELECT DISTINCT order_id FROM stg.orders) o
  ON o.order_id = r.order_id;


SELECT MIN(order_date) AS min_order_date, MAX(order_date) AS max_order_date FROM stg.orders;
SELECT MIN(ship_date)  AS min_ship_date,  MAX(ship_date)  AS max_ship_date  FROM stg.orders;


SELECT
  COUNT(*) FILTER (WHERE so.order_date IS NULL AND NULLIF(TRIM(ro.order_date), '') IS NOT NULL) AS order_date_parse_failed,
  COUNT(*) FILTER (WHERE so.ship_date  IS NULL AND NULLIF(TRIM(ro.ship_date),  '') IS NOT NULL) AS ship_date_parse_failed
FROM raw.orders ro
JOIN stg.orders so
  ON so.row_id = NULLIF(TRIM(ro.row_id), '')::int;

SELECT
  COUNT(*) FILTER (WHERE so.sales    IS NULL AND NULLIF(TRIM(ro.sales),    '') IS NOT NULL) AS sales_parse_failed,
  COUNT(*) FILTER (WHERE so.profit   IS NULL AND NULLIF(TRIM(ro.profit),   '') IS NOT NULL) AS profit_parse_failed,
  COUNT(*) FILTER (WHERE so.discount IS NULL AND NULLIF(TRIM(ro.discount), '') IS NOT NULL) AS discount_parse_failed,
  COUNT(*) FILTER (WHERE so.quantity IS NULL AND NULLIF(TRIM(ro.quantity), '') IS NOT NULL) AS quantity_parse_failed
FROM raw.orders ro
JOIN stg.orders so
  ON so.row_id = NULLIF(TRIM(ro.row_id), '')::int;