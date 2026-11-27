USE FraudLens;
GO
SELECT t.name AS table_name,
       (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = t.object_id) AS column_count
FROM sys.tables t
WHERE t.schema_id = SCHEMA_ID('stg')
ORDER BY t.name;
GO
SELECT name AS view_name FROM sys.views WHERE schema_id = SCHEMA_ID('stg') ORDER BY name;
GO
SELECT type_desc, COUNT(*) AS how_many
FROM sys.objects
WHERE schema_id = SCHEMA_ID('stg') AND type IN ('PK', 'D')
GROUP BY type_desc
ORDER BY type_desc;
GO