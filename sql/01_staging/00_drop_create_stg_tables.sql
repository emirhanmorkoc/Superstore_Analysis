-- =========================================================
-- STAGING TABLES
-- Purpose: Create typed staging tables for cleaned source data.
-- Notes: Staging applies basic standardization and prepares data for mart modeling.
-- =========================================================

BEGIN;

DROP TABLE IF EXISTS stg.orders;
DROP TABLE IF EXISTS stg.returns;

CREATE TABLE stg.orders (
  row_id        INT,
  order_id      TEXT,
  order_date    DATE,
  ship_date     DATE,
  ship_mode     TEXT,
  customer_id   TEXT,
  customer_name TEXT,
  segment       TEXT,
  country       TEXT,
  city          TEXT,
  state         TEXT,
  postal_code   TEXT,
  region        TEXT,
  product_id    TEXT,
  category      TEXT,
  sub_category  TEXT,
  product_name  TEXT,
  sales         NUMERIC(12,4),
  quantity      INT,
  discount      NUMERIC(6,4),
  profit        NUMERIC(12,4)
);

CREATE TABLE stg.returns (
  returned TEXT,
  order_id TEXT
);

COMMIT;