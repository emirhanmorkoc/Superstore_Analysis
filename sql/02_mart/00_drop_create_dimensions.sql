-- =========================================================
-- MART DIMENSIONS
-- Purpose: Create dimension tables for the analytical star schema.
-- Notes: Dimensions support reporting by date, customer, product, geography, and ship mode.
-- =========================================================

BEGIN;

DROP TABLE IF EXISTS mart.fact_sales;
DROP TABLE IF EXISTS mart.dim_ship_mode;
DROP TABLE IF EXISTS mart.dim_geo;
DROP TABLE IF EXISTS mart.dim_product;
DROP TABLE IF EXISTS mart.dim_customer;
DROP TABLE IF EXISTS mart.dim_date;


CREATE TABLE mart.dim_date (
    date_key        INTEGER PRIMARY KEY,
    date_value      DATE NOT NULL UNIQUE,
    year            SMALLINT NOT NULL,
    quarter         SMALLINT NOT NULL CHECK (quarter BETWEEN 1 AND 4),
    month           SMALLINT NOT NULL CHECK (month BETWEEN 1 AND 12),
    month_name      TEXT NOT NULL,
    day_of_month    SMALLINT NOT NULL CHECK (day_of_month BETWEEN 1 AND 31),
    day_of_week     SMALLINT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    day_name        TEXT NOT NULL,
    week_of_year    SMALLINT NOT NULL CHECK (week_of_year BETWEEN 1 AND 53),
    is_weekend      BOOLEAN NOT NULL
);


CREATE TABLE mart.dim_customer (
    customer_key    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     TEXT NOT NULL UNIQUE,
    customer_name   TEXT,
    segment         TEXT
);


CREATE TABLE mart.dim_product (
    product_key     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id      TEXT NOT NULL,
    product_name    TEXT,
    category        TEXT,
    sub_category    TEXT,
    CONSTRAINT uq_dim_product UNIQUE (product_id, product_name, category, sub_category)
);


CREATE TABLE mart.dim_geo (
    geo_key         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country         TEXT,
    region          TEXT,
    state           TEXT,
    city            TEXT,
    postal_code     TEXT,
    CONSTRAINT uq_dim_geo UNIQUE (country, region, state, city, postal_code)
);


CREATE TABLE mart.dim_ship_mode (
    ship_mode_key   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ship_mode       TEXT NOT NULL UNIQUE
);


INSERT INTO mart.dim_customer (customer_id, customer_name, segment)
SELECT
    o.customer_id,
    MAX(o.customer_name) AS customer_name,
    MAX(o.segment)       AS segment
FROM stg.orders o
WHERE o.customer_id IS NOT NULL
GROUP BY o.customer_id;


INSERT INTO mart.dim_product (product_id, product_name, category, sub_category)
SELECT DISTINCT
    o.product_id,
    o.product_name,
    o.category,
    o.sub_category
FROM stg.orders o
WHERE o.product_id IS NOT NULL;


INSERT INTO mart.dim_geo (country, region, state, city, postal_code)
SELECT DISTINCT
    o.country,
    o.region,
    o.state,
    o.city,
    o.postal_code
FROM stg.orders o;


INSERT INTO mart.dim_ship_mode (ship_mode)
SELECT DISTINCT
    o.ship_mode
FROM stg.orders o
WHERE o.ship_mode IS NOT NULL;


WITH bounds AS (
    SELECT
        LEAST(MIN(o.order_date), MIN(o.ship_date)) AS min_d,
        GREATEST(MAX(o.order_date), MAX(o.ship_date)) AS max_d
    FROM stg.orders o
),
dates AS (
    SELECT generate_series(b.min_d, b.max_d, interval '1 day')::date AS d
    FROM bounds b
    WHERE b.min_d IS NOT NULL AND b.max_d IS NOT NULL
)
INSERT INTO mart.dim_date (
    date_key, date_value, year, quarter, month, month_name,
    day_of_month, day_of_week, day_name, week_of_year, is_weekend
)
SELECT
    (EXTRACT(YEAR  FROM d)::int * 10000
   + EXTRACT(MONTH FROM d)::int * 100
   + EXTRACT(DAY   FROM d)::int) AS date_key,
    d AS date_value,
    EXTRACT(YEAR FROM d)::smallint AS year,
    EXTRACT(QUARTER FROM d)::smallint AS quarter,
    EXTRACT(MONTH FROM d)::smallint AS month,
    TO_CHAR(d, 'Mon') AS month_name,
    EXTRACT(DAY FROM d)::smallint AS day_of_month,
    EXTRACT(ISODOW FROM d)::smallint AS day_of_week,
    TO_CHAR(d, 'Dy') AS day_name,
    EXTRACT(WEEK FROM d)::smallint AS week_of_year,
    (EXTRACT(ISODOW FROM d) IN (6,7)) AS is_weekend
FROM dates
ORDER BY d;


COMMIT;