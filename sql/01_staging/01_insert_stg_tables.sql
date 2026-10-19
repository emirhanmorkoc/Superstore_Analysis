-- =========================================================
-- STAGING LOAD
-- Purpose: Insert cleaned and typed data from raw into staging tables.
-- Notes: Includes trimming, null handling, and type conversion.
-- =========================================================

BEGIN;

INSERT INTO stg.orders (
  row_id, order_id, order_date, ship_date, ship_mode,
  customer_id, customer_name, segment,
  country, city, state, postal_code, region,
  product_id, category, sub_category, product_name,
  sales, quantity, discount, profit
)
SELECT
  NULLIF(TRIM(row_id), '')::int,
  NULLIF(TRIM(order_id), ''),

  CASE
    WHEN NULLIF(TRIM(order_date), '') ~ '^\d{2}\.\d{2}\.\d{4}$'
      THEN to_date(TRIM(order_date), 'DD.MM.YYYY')
    ELSE NULL
  END AS order_date,
  CASE
    WHEN NULLIF(TRIM(ship_date), '') ~ '^\d{2}\.\d{2}\.\d{4}$'
      THEN to_date(TRIM(ship_date), 'DD.MM.YYYY')
    ELSE NULL
  END AS ship_date,

  NULLIF(TRIM(ship_mode), ''),

  NULLIF(TRIM(customer_id), ''),
  NULLIF(TRIM(customer_name), ''),
  NULLIF(TRIM(segment), ''),

  NULLIF(TRIM(country), ''),
  NULLIF(TRIM(city), ''),
  NULLIF(TRIM(state), ''),
  NULLIF(TRIM(postal_code), ''),
  NULLIF(TRIM(region), ''),

  NULLIF(TRIM(product_id), ''),
  NULLIF(TRIM(category), ''),
  NULLIF(TRIM(sub_category), ''),
  NULLIF(TRIM(product_name), ''),

  NULLIF(REPLACE(TRIM(sales),    ',', '.'), '')::numeric(12,4),
  NULLIF(TRIM(quantity), '')::int,
  NULLIF(REPLACE(TRIM(discount), ',', '.'), '')::numeric(6,4),
  NULLIF(REPLACE(TRIM(profit),   ',', '.'), '')::numeric(12,4)
FROM raw.orders;

INSERT INTO stg.returns (returned, order_id)
SELECT
  NULLIF(TRIM(returned), ''),
  NULLIF(TRIM(order_id), '')
FROM raw.returns;

COMMIT;