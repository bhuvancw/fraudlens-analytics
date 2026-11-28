USE FraudLens;
GO
SELECT 'users_raw' AS table_name, COUNT(*) AS row_count FROM stg.users_raw
UNION ALL
SELECT 'cards_raw', COUNT(*) FROM stg.cards_raw;
GO
-- A stray carriage return in the last column would mean the line endings were read wrongly
SELECT COUNT(*) AS rows_with_carriage_return
FROM stg.cards_raw
WHERE card_on_dark_web LIKE '%' + CHAR(13) + '%';
GO
SELECT card_on_dark_web, COUNT(*) AS how_many
FROM stg.cards_raw
GROUP BY card_on_dark_web
ORDER BY card_on_dark_web;
GO
SELECT table_name, source_file, rows_loaded FROM stg.load_log ORDER BY load_id;
GO