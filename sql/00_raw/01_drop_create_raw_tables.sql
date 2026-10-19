-- =========================================================
-- RAW TABLES
-- Purpose: Create raw landing tables for source CSV files.
-- Notes: All columns are stored as TEXT to preserve source values 1:1.
-- =========================================================

BEGIN;

DROP TABLE IF EXISTS raw.orders;
DROP TABLE IF EXISTS raw.returns;

CREATE TABLE raw.orders (
  row_id         TEXT,
  order_id       TEXT,
  order_date     TEXT,
  ship_date      TEXT,
  ship_mode      TEXT,
  customer_id    TEXT,
  customer_name  TEXT,
  segment        TEXT,
  country        TEXT,
  city           TEXT,
  state          TEXT,
  postal_code    TEXT,
  region         TEXT,
  product_id     TEXT,
  category       TEXT,
  sub_category   TEXT,
  product_name   TEXT,
  sales          TEXT,
  quantity       TEXT,
  discount       TEXT,
  profit         TEXT
);

CREATE TABLE raw.returns (
  returned  TEXT,
  order_id  TEXT
);

COMMIT;