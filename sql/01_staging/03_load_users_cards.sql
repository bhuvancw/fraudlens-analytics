-- FraudLens: load the users and cards files into staging.

USE FraudLens;
GO

TRUNCATE TABLE stg.users_raw;
TRUNCATE TABLE stg.cards_raw;
GO

BULK INSERT stg.v_users_load
FROM 'C:\projects\fraudlens-analytics\data\raw\sd254_users.csv'
WITH (
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

BULK INSERT stg.v_cards_load
FROM 'C:\projects\fraudlens-analytics\data\raw\sd254_cards.csv'
WITH (
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIRSTROW = 2,
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

INSERT INTO stg.load_log (table_name, source_file, rows_loaded)
SELECT 'stg.users_raw', 'sd254_users.csv', COUNT(*) FROM stg.users_raw;
INSERT INTO stg.load_log (table_name, source_file, rows_loaded)
SELECT 'stg.cards_raw', 'sd254_cards.csv', COUNT(*) FROM stg.cards_raw;
GO