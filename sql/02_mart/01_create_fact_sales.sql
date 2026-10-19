-- =========================================================
-- MART FACT TABLE
-- Purpose: Create the central sales fact table for analysis and reporting.
-- Notes: Grain = one row per order line.
-- =========================================================

BEGIN;

DROP TABLE IF EXISTS mart.fact_sales;

CREATE TABLE mart.fact_sales (
    sales_key           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    row_id              BIGINT,
    order_id            TEXT NOT NULL,
    order_date_key      INTEGER NOT NULL REFERENCES mart.dim_date(date_key),
    ship_date_key       INTEGER NOT NULL REFERENCES mart.dim_date(date_key),
    customer_key        BIGINT NOT NULL REFERENCES mart.dim_customer(customer_key),
    product_key         BIGINT NOT NULL REFERENCES mart.dim_product(product_key),
    geo_key             BIGINT NOT NULL REFERENCES mart.dim_geo(geo_key),
    ship_mode_key       BIGINT REFERENCES mart.dim_ship_mode(ship_mode_key),
    sales               NUMERIC(18, 4) NOT NULL,
    profit              NUMERIC(18, 4) NOT NULL,
    discount            NUMERIC(9, 4)  NOT NULL,
    quantity            INTEGER NOT NULL,
    days_to_ship        SMALLINT NOT NULL CHECK (days_to_ship >= 0),
    is_returned         BOOLEAN NOT NULL DEFAULT FALSE
);


INSERT INTO mart.fact_sales (
    row_id,
    order_id,
    order_date_key,
    ship_date_key,
    customer_key,
    product_key,
    geo_key,
    ship_mode_key,
    sales,
    profit,
    discount,
    quantity,
    days_to_ship,
    is_returned
)
SELECT
    o.row_id,
    o.order_id,
    dd_order.date_key AS order_date_key,
    dd_ship.date_key  AS ship_date_key,
    dc.customer_key,
    dp.product_key,
    dg.geo_key,
    dsm.ship_mode_key,
    o.sales,
    o.profit,
    o.discount,
    o.quantity,
    (o.ship_date - o.order_date)::smallint AS days_to_ship,
    (r.order_id IS NOT NULL) AS is_returned
FROM stg.orders o
JOIN mart.dim_date dd_order
  ON dd_order.date_value = o.order_date
JOIN mart.dim_date dd_ship
  ON dd_ship.date_value = o.ship_date
JOIN mart.dim_customer dc
  ON dc.customer_id = o.customer_id
JOIN mart.dim_product dp
  ON dp.product_id = o.product_id
 AND dp.product_name IS NOT DISTINCT FROM o.product_name
 AND dp.category     IS NOT DISTINCT FROM o.category
 AND dp.sub_category IS NOT DISTINCT FROM o.sub_category
JOIN mart.dim_geo dg
  ON dg.country     IS NOT DISTINCT FROM o.country
 AND dg.region      IS NOT DISTINCT FROM o.region
 AND dg.state       IS NOT DISTINCT FROM o.state
 AND dg.city        IS NOT DISTINCT FROM o.city
 AND dg.postal_code IS NOT DISTINCT FROM o.postal_code
LEFT JOIN mart.dim_ship_mode dsm
  ON dsm.ship_mode = o.ship_mode
LEFT JOIN (
    SELECT DISTINCT order_id
    FROM stg.returns
    WHERE order_id IS NOT NULL
) r
  ON r.order_id = o.order_id
WHERE o.order_id IS NOT NULL;

COMMIT;