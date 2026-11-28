-- Drop the two staging tables that need an explicit row number.

USE FraudLens;
GO

DROP VIEW IF EXISTS stg.v_users_load;
DROP VIEW IF EXISTS stg.v_card_transaction_load;
DROP TABLE IF EXISTS stg.users_raw;
DROP TABLE IF EXISTS stg.card_transaction_raw;
GO