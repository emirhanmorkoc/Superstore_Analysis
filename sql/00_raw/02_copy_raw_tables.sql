-- =========================================================
-- RAW LOAD
-- Purpose: Load source CSV files into raw tables.
-- Notes: Replace paths with local file paths before running.
-- =========================================================

BEGIN;

TRUNCATE TABLE raw.orders;
TRUNCATE TABLE raw.returns;

COPY raw.orders
FROM 'E:\Projects\Superstore_Analysis\data\orders.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';'
);

COPY raw.returns
FROM 'E:\Projects\Superstore_Analysis\data\returns.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ';'
);

COMMIT;