SELECT name, recovery_model_desc FROM sys.databases WHERE name = 'FraudLens';
GO
USE FraudLens;
GO
SELECT name FROM sys.schemas WHERE name IN ('stg', 'core', 'dw', 'dq') ORDER BY name;
GO
SELECT CAST(value_in_use AS INT) FROM sys.configurations WHERE name = 'max server memory (MB)';
GO