-- =========================================================
-- STAGING INDEXES
-- Purpose: Add supporting indexes to staging tables.
-- Notes: Improves joins and downstream mart build performance.
-- =========================================================

CREATE INDEX IF NOT EXISTS idx_stg_orders_order_date  ON stg.orders(order_date);
CREATE INDEX IF NOT EXISTS idx_stg_orders_customer_id ON stg.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_stg_orders_product_id  ON stg.orders(product_id);
CREATE INDEX IF NOT EXISTS idx_stg_orders_order_id    ON stg.orders(order_id);