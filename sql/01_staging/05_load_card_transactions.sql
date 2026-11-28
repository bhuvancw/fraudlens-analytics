-- FraudLens: load the transaction file into staging (about 24.4 million rows).
-- Re-runnable: staging is truncated first.

USE FraudLens;
GO

TRUNCATE TABLE stg.card_transaction_raw;
GO

BULK INSERT stg.v_card_transaction_load
FROM 'C:\projects\fraudlens-analytics\data\raw\card_transaction.v1.csv'
WITH (
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    BATCHSIZE = 1000000,
    TABLOCK
);
GO

INSERT INTO stg.load_log (table_name, source_file, rows_loaded)
SELECT 'stg.card_transaction_raw', 'card_transaction.v1.csv', COUNT(*) FROM stg.card_transaction_raw;
GO