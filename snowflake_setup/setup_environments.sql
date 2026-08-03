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
-- Keys were generated locally on 2026-08-03.
-- Private keys (.p8 files) are in: snowflake_setup/rsa_keys/  (DO NOT COMMIT)
-- Run these statements as ACCOUNTADMIN:
-- -----------------------------------------------------------------------------
ALTER USER SVC_DBT_DEV  SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwatfgq/ndy61qHla9vOdnzA+MHRfFXc2iCrix5KzvPHE7KkPuPksNvsNXgObJxbUZ2J6lOLVztKdYDH+0MSIKvJ+g7YF8YJGjVrUpdSQqiqthLLcMnHqiSLiGnEPlX87HfZ4neQbUMMtFok7iMqEh72KZ8Su3x8oK3CAXlmxP8EAD4a82FreyxDs5vsiiyYUMJMnA28wBQIU8Uxpro9N1YsD8kkV4gDfVamSnCaDhslBb6Z3OP5+gzd6NFU7R3ldQDJazKj9gWSftP5WnM9RL5Om4VtdCxfEkHSl9XFoCY0qql/Qqjr4Be3DxT8ZDLrBa+4X9zjNtjQLo9vFj4KN1QIDAQAB';
ALTER USER SVC_DBT_SIT  SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmJ/k7IDcM/bb2Y3If1OiKp0VZy3FeHxNv1IXQf8MJOv7tg26zY1QUAVKmhnyE3nYruGtGYr1mHwnCrf8D3s23/Sb/CpKWS4T/5gIexySA5zKgw0aV1tZxww1BYrziktAmGPPu6kyg6p226LGbRGCq30a0AqV1RTsMllMb4pxYjcMxOLUnHxcFD76iyQRql8hVneqidvgR9XD4CJjAD+9jwpRvuo3gCIkYg7VorFHSHau/u1PEFb4FvrojmfsOrPrjci11732tJm5dokxcYWgJXPkFiOZXMtO/QeQnMGz0ZAs4Mma9egCoj6Yelxg4rWapZV4zeTexZJ3PRY78oOV9wIDAQAB';
ALTER USER SVC_DBT_UAT  SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsqP/6NVZFt9PzASj7ThGihzIvpastBnCx2lVmMG/vAgaTrhwSBAGroYrdOQDIZgJU+MCowi5ag07Prys7ZK8tMz4IofyiDO7X/c2gVtKb5azWfmCraKDYR6z3pdReUzxZcYmjL90wfRR30e5rcZxklXcdfzG/4MEJ2zyMPiz84UTUXDr8aBItEf2jRI+YkIiclFa3jnyrls2sDo3FD6NFGTmCRlxY+j2gCgx06sPQLwYPAnXNlnKSoMkzvYwSzQAhfwWP1zngXRTiDy8nM6AzxUJ6A+jK3N0GwJiNwa0kHjPZeZJIJFUmRoVq50hP1LocWmGffHSbRc9396PsKyq7wIDAQAB';
ALTER USER SVC_DBT_PROD SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu2LbeZKKEBXpULtFBKiUWvRPePh6P3QXAAsFaC0pAUdY2JzWksqZsF2YAFaOQZWWsBe4c6kQEAEJixf1EzvhVQ2x6TevlgT7ia9YEZHZtcT0Y72DZuCNIx12QjON40L8YM1axP3jBXzWF4uIVdrdZTrvd1MB9si+GXAFC77DQastUCyOMTvS0+Cz0F9bIFV8cdMRf5lXTVJVV7dZzoRQHYI7m/ipOKMUbiW2nkEktav9T7npQrv7Ei+CszXUqJflHWE7Yz5EtHjyXuKEyIoUoSk9NZB0bHNuJ+ABUOZm9A+8Jg/b/hvoK3nZjsvWn0/ojI8XMDa7drAe/A2xPUsNkQIDAQAB';

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
