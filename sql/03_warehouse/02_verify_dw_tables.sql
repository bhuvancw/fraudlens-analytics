USE FraudLens;
GO
SELECT t.name AS table_name,
       (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = t.object_id) AS column_count
FROM sys.tables t
WHERE t.schema_id = SCHEMA_ID('dw')
ORDER BY t.name;
GO
SELECT type_desc, COUNT(*) AS how_many
FROM sys.objects
WHERE schema_id = SCHEMA_ID('dw') AND type IN ('PK', 'UQ', 'C', 'D')
GROUP BY type_desc
ORDER BY type_desc;
GO
SELECT COUNT(*) AS unknown_members FROM (
    SELECT customer_key AS k FROM dw.dim_customer WHERE customer_key = -1
    UNION ALL SELECT card_key FROM dw.dim_card WHERE card_key = -1
    UNION ALL SELECT merchant_key FROM dw.dim_merchant WHERE merchant_key = -1
    UNION ALL SELECT geography_key FROM dw.dim_geography WHERE geography_key = -1
    UNION ALL SELECT mcc_key FROM dw.dim_mcc WHERE mcc_key = -1
    UNION ALL SELECT profile_key FROM dw.dim_transaction_profile WHERE profile_key = -1
    UNION ALL SELECT error_combination_key FROM dw.dim_error_combination WHERE error_combination_key = -1
) AS u;
GO