-- =========================================================
-- MART INDEXES
-- Purpose: Add supporting indexes to the fact and dimension tables.
-- Notes: Designed for analytical joins and reporting queries.
-- =========================================================

BEGIN;

CREATE INDEX IF NOT EXISTS ix_fact_sales_order_date_key
    ON mart.fact_sales (order_date_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_ship_date_key
    ON mart.fact_sales (ship_date_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_customer_key
    ON mart.fact_sales (customer_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_product_key
    ON mart.fact_sales (product_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_geo_key
    ON mart.fact_sales (geo_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_ship_mode_key
    ON mart.fact_sales (ship_mode_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_is_returned
    ON mart.fact_sales (is_returned);

CREATE INDEX IF NOT EXISTS ix_fact_sales_order_id
    ON mart.fact_sales (order_id);

COMMIT;