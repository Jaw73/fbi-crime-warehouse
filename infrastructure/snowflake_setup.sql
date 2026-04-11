-- ============================================================
-- FBI Crime Analytics Warehouse — Snowflake Provisioning
-- Author: Jayshawn Whitfield
-- Purpose: Provision warehouse, database, schemas, role, and
--          user for the FBI Crime Analytics dbt project.
-- ============================================================
-- This script follows least-privilege RBAC principles:
--   1. A dedicated role (FBI_DBT_ROLE) owns the database
--   2. A dedicated service user (FBI_DBT_USER) is granted that role
--   3. dbt connects using the service user, never ACCOUNTADMIN
-- Run as: ACCOUNTADMIN
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- ----- 1. Warehouse -----
-- X-Small is the smallest/cheapest size, perfect for portfolio work.
-- Auto-suspend after 60s of inactivity to preserve trial credits.
CREATE WAREHOUSE IF NOT EXISTS FBI_CRIME_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Compute warehouse for FBI Crime Analytics dbt project';

-- ----- 2. Database and Schemas -----
CREATE DATABASE IF NOT EXISTS FBI_CRIME_DB
    COMMENT = 'FBI Crime Data Explorer analytics warehouse';

USE DATABASE FBI_CRIME_DB;

CREATE SCHEMA IF NOT EXISTS RAW       COMMENT = 'Untransformed data loaded from FBI Crime Data Explorer API';
CREATE SCHEMA IF NOT EXISTS STAGING   COMMENT = 'dbt staging models — light renaming and casting';
CREATE SCHEMA IF NOT EXISTS MARTS     COMMENT = 'dbt mart models — fact and dimension tables';
CREATE SCHEMA IF NOT EXISTS SNAPSHOTS COMMENT = 'dbt snapshots — SCD Type 2 history';

-- ----- 3. Role and Permissions -----
CREATE ROLE IF NOT EXISTS FBI_DBT_ROLE
    COMMENT = 'Role used by dbt for the FBI Crime Analytics project';

-- Warehouse usage
GRANT USAGE ON WAREHOUSE FBI_CRIME_WH TO ROLE FBI_DBT_ROLE;
GRANT OPERATE ON WAREHOUSE FBI_CRIME_WH TO ROLE FBI_DBT_ROLE;

-- Database and schema access
GRANT USAGE ON DATABASE FBI_CRIME_DB TO ROLE FBI_DBT_ROLE;
GRANT CREATE SCHEMA ON DATABASE FBI_CRIME_DB TO ROLE FBI_DBT_ROLE;

GRANT ALL PRIVILEGES ON SCHEMA FBI_CRIME_DB.RAW       TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA FBI_CRIME_DB.STAGING   TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA FBI_CRIME_DB.MARTS     TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA FBI_CRIME_DB.SNAPSHOTS TO ROLE FBI_DBT_ROLE;

-- Future grants — anything dbt creates later inherits these privileges
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA FBI_CRIME_DB.RAW       TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA FBI_CRIME_DB.STAGING   TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA FBI_CRIME_DB.MARTS     TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA FBI_CRIME_DB.SNAPSHOTS TO ROLE FBI_DBT_ROLE;

GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA FBI_CRIME_DB.RAW       TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA FBI_CRIME_DB.STAGING   TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA FBI_CRIME_DB.MARTS     TO ROLE FBI_DBT_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA FBI_CRIME_DB.SNAPSHOTS TO ROLE FBI_DBT_ROLE;

-- ----- 4. Service User for dbt -----
-- IMPORTANT: Replace 'CHANGE_ME_WITH_STRONG_PASSWORD' with a strong password
-- before running this script. Save the password in your password manager.
CREATE USER IF NOT EXISTS FBI_DBT_USER
    PASSWORD = '<REPLACE_WITH_STRONG_PASSWORD_BEFORE_RUNNING>'
    LOGIN_NAME = 'FBI_DBT_USER'
    DISPLAY_NAME = 'FBI dbt Service User'
    DEFAULT_WAREHOUSE = FBI_CRIME_WH
    DEFAULT_ROLE = FBI_DBT_ROLE
    DEFAULT_NAMESPACE = FBI_CRIME_DB.STAGING
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Service account for dbt FBI Crime Analytics project';

GRANT ROLE FBI_DBT_ROLE TO USER FBI_DBT_USER;

-- ----- 5. Verification -----
SHOW WAREHOUSES LIKE 'FBI_CRIME_WH';
SHOW DATABASES   LIKE 'FBI_CRIME_DB';
SHOW SCHEMAS IN DATABASE FBI_CRIME_DB;
SHOW ROLES LIKE 'FBI_DBT_ROLE';
SHOW USERS LIKE 'FBI_DBT_USER';
