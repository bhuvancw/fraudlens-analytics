-- FraudLens: database, schemas and server settings
-- Run once. Safe to re-run.

USE master;
GO

-- Cap SQL Server memory at 3 GB (instance-wide setting)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'max server memory (MB)', 3072;
RECONFIGURE;
GO

IF DB_ID('FraudLens') IS NULL
    CREATE DATABASE FraudLens;
GO

-- Simple recovery: the log is reused instead of growing during big loads
ALTER DATABASE FraudLens SET RECOVERY SIMPLE;
GO

USE FraudLens;
GO

-- CREATE SCHEMA must be the only statement in its batch, hence EXEC
IF SCHEMA_ID('stg')  IS NULL EXEC('CREATE SCHEMA stg');
IF SCHEMA_ID('core') IS NULL EXEC('CREATE SCHEMA core');
IF SCHEMA_ID('dw')   IS NULL EXEC('CREATE SCHEMA dw');
IF SCHEMA_ID('dq')   IS NULL EXEC('CREATE SCHEMA dq');
GO