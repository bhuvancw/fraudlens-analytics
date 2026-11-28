USE FraudLens;
GO
SELECT COUNT(*) AS total_rows FROM stg.card_transaction_raw;
GO
SELECT COUNT(*) AS rows_with_carriage_return
FROM stg.card_transaction_raw
WHERE is_fraud LIKE '%' + CHAR(13) + '%';
GO
SELECT is_fraud, COUNT(*) AS how_many
FROM stg.card_transaction_raw
GROUP BY is_fraud
ORDER BY is_fraud;
GO
SELECT use_chip, COUNT(*) AS how_many
FROM stg.card_transaction_raw
GROUP BY use_chip
ORDER BY use_chip;
GO
SELECT
    SUM(CASE WHEN merchant_state IS NULL OR merchant_state = '' THEN 1 ELSE 0 END) AS blank_state,
    SUM(CASE WHEN zip IS NULL OR zip = '' THEN 1 ELSE 0 END) AS blank_zip,
    SUM(CASE WHEN errors IS NULL OR errors = '' THEN 1 ELSE 0 END) AS blank_errors,
    SUM(CASE WHEN merchant_city = ' ONLINE' THEN 1 ELSE 0 END) AS online_with_leading_space,
    SUM(CASE WHEN merchant_city = 'ONLINE' THEN 1 ELSE 0 END) AS online_clean
FROM stg.card_transaction_raw;
GO
SELECT COUNT(DISTINCT merchant_name) AS distinct_merchants,
       COUNT(DISTINCT mcc) AS distinct_mcc
FROM stg.card_transaction_raw;
GO
EXEC sp_spaceused 'stg.card_transaction_raw';
GO
SELECT table_name, source_file, rows_loaded FROM stg.load_log ORDER BY load_id;
GO