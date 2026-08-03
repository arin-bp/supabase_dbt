-- =============================================================================
-- Snowflake Setup Script for supabase_dbt Multi-Environment CI/CD
-- Run as ACCOUNTADMIN or SYSADMIN
-- =============================================================================

-- -----------------------------------------------------------------------------
-- STEP 1: Create databases (one per environment)
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS SUPABASE_DEV;
CREATE DATABASE IF NOT EXISTS SUPABASE_SIT;
CREATE DATABASE IF NOT EXISTS SUPABASE_UAT;
CREATE DATABASE IF NOT EXISTS SUPABASE_PROD;

-- -----------------------------------------------------------------------------
-- STEP 2: Create warehouses (separate for cost tracking + auto-suspend)
-- -----------------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS SUPABASE_DEV_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

CREATE WAREHOUSE IF NOT EXISTS SUPABASE_SIT_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

CREATE WAREHOUSE IF NOT EXISTS SUPABASE_UAT_WH
    WITH WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

CREATE WAREHOUSE IF NOT EXISTS SUPABASE_PROD_WH
    WITH WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

-- -----------------------------------------------------------------------------
-- STEP 3: Create least-privilege roles per environment
-- -----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS DBT_DEV_ROLE;
CREATE ROLE IF NOT EXISTS DBT_SIT_ROLE;
CREATE ROLE IF NOT EXISTS DBT_UAT_ROLE;
CREATE ROLE IF NOT EXISTS DBT_PROD_ROLE;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE SUPABASE_DEV_WH  TO ROLE DBT_DEV_ROLE;
GRANT USAGE ON WAREHOUSE SUPABASE_SIT_WH  TO ROLE DBT_SIT_ROLE;
GRANT USAGE ON WAREHOUSE SUPABASE_UAT_WH  TO ROLE DBT_UAT_ROLE;
GRANT USAGE ON WAREHOUSE SUPABASE_PROD_WH TO ROLE DBT_PROD_ROLE;

-- Grant database access
GRANT USAGE ON DATABASE SUPABASE_DEV  TO ROLE DBT_DEV_ROLE;
GRANT USAGE ON DATABASE SUPABASE_SIT  TO ROLE DBT_SIT_ROLE;
GRANT USAGE ON DATABASE SUPABASE_UAT  TO ROLE DBT_UAT_ROLE;
GRANT USAGE ON DATABASE SUPABASE_PROD TO ROLE DBT_PROD_ROLE;

-- Grant schema + table level access (CREATE for dbt to build tables)
GRANT CREATE SCHEMA ON DATABASE SUPABASE_DEV  TO ROLE DBT_DEV_ROLE;
GRANT CREATE SCHEMA ON DATABASE SUPABASE_SIT  TO ROLE DBT_SIT_ROLE;
GRANT CREATE SCHEMA ON DATABASE SUPABASE_UAT  TO ROLE DBT_UAT_ROLE;
GRANT CREATE SCHEMA ON DATABASE SUPABASE_PROD TO ROLE DBT_PROD_ROLE;

-- Allow all roles to read from the source database (raw zone)
GRANT USAGE  ON DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_DEV_ROLE;
GRANT USAGE  ON DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_SIT_ROLE;
GRANT USAGE  ON DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_UAT_ROLE;
GRANT USAGE  ON DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_PROD_ROLE;
GRANT USAGE  ON ALL SCHEMAS IN DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_DEV_ROLE;
GRANT USAGE  ON ALL SCHEMAS IN DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_SIT_ROLE;
GRANT USAGE  ON ALL SCHEMAS IN DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_UAT_ROLE;
GRANT USAGE  ON ALL SCHEMAS IN DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_PROD_ROLE;
GRANT SELECT ON ALL TABLES  IN DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_DEV_ROLE;
GRANT SELECT ON ALL TABLES  IN DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_SIT_ROLE;
GRANT SELECT ON ALL TABLES  IN DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_UAT_ROLE;
GRANT SELECT ON ALL TABLES  IN DATABASE SOLVEFINS_DATA_V2 TO ROLE DBT_PROD_ROLE;

-- -----------------------------------------------------------------------------
-- STEP 4: Create service accounts (CI/CD uses these — NOT personal accounts)
-- -----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS SVC_DBT_DEV
    LOGIN_NAME    = 'SVC_DBT_DEV'
    DISPLAY_NAME  = 'dbt Service Account - DEV'
    DEFAULT_ROLE  = DBT_DEV_ROLE
    DEFAULT_WAREHOUSE = SUPABASE_DEV_WH
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS SVC_DBT_SIT
    LOGIN_NAME    = 'SVC_DBT_SIT'
    DISPLAY_NAME  = 'dbt Service Account - SIT'
    DEFAULT_ROLE  = DBT_SIT_ROLE
    DEFAULT_WAREHOUSE = SUPABASE_SIT_WH
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS SVC_DBT_UAT
    LOGIN_NAME    = 'SVC_DBT_UAT'
    DISPLAY_NAME  = 'dbt Service Account - UAT'
    DEFAULT_ROLE  = DBT_UAT_ROLE
    DEFAULT_WAREHOUSE = SUPABASE_UAT_WH
    MUST_CHANGE_PASSWORD = FALSE;

CREATE USER IF NOT EXISTS SVC_DBT_PROD
    LOGIN_NAME    = 'SVC_DBT_PROD'
    DISPLAY_NAME  = 'dbt Service Account - PROD'
    DEFAULT_ROLE  = DBT_PROD_ROLE
    DEFAULT_WAREHOUSE = SUPABASE_PROD_WH
    MUST_CHANGE_PASSWORD = FALSE;

-- Assign roles to service accounts
GRANT ROLE DBT_DEV_ROLE  TO USER SVC_DBT_DEV;
GRANT ROLE DBT_SIT_ROLE  TO USER SVC_DBT_SIT;
GRANT ROLE DBT_UAT_ROLE  TO USER SVC_DBT_UAT;
GRANT ROLE DBT_PROD_ROLE TO USER SVC_DBT_PROD;

-- -----------------------------------------------------------------------------
-- STEP 5: Set RSA public keys on service accounts
-- (Generate key pairs locally first — see README below)
-- Replace placeholders with actual public key content (no header/footer lines)
-- -----------------------------------------------------------------------------
-- ALTER USER SVC_DBT_DEV  SET RSA_PUBLIC_KEY='MIIBIjANBgkq... (dev public key)';
-- ALTER USER SVC_DBT_SIT  SET RSA_PUBLIC_KEY='MIIBIjANBgkq... (sit public key)';
-- ALTER USER SVC_DBT_UAT  SET RSA_PUBLIC_KEY='MIIBIjANBgkq... (uat public key)';
-- ALTER USER SVC_DBT_PROD SET RSA_PUBLIC_KEY='MIIBIjANBgkq... (prod public key)';

-- -----------------------------------------------------------------------------
-- VERIFICATION
-- -----------------------------------------------------------------------------
-- SHOW DATABASES LIKE 'SUPABASE_%';
-- SHOW WAREHOUSES LIKE 'SUPABASE_%';
-- SHOW ROLES LIKE 'DBT_%';
-- SHOW USERS LIKE 'SVC_DBT_%';

-- =============================================================================
-- RSA KEY GENERATION (run locally in PowerShell/bash — NOT in Snowflake)
-- =============================================================================
-- # Generate one key pair per service account:
-- openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out svc_dbt_dev_key.p8 -nocrypt
-- openssl rsa -in svc_dbt_dev_key.p8 -pubout -out svc_dbt_dev_key.pub
--
-- # The .pub file content (minus header/footer) goes into ALTER USER above
-- # The .p8 file content goes into GitHub Secret SNOWFLAKE_PRIVATE_KEY_DEV
-- # Repeat for sit, uat, prod
