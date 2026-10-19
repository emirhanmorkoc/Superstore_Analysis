-- =========================================================
-- SCHEMA SETUP
-- Purpose: Create logical layers for the project pipeline.
-- Notes: raw = landing, stg = cleaned/typed source, mart = analytical model.
-- =========================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS mart;

COMMIT;