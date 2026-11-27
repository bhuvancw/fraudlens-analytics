USE FraudLens;
GO
SELECT t.name AS table_name,
       (SELECT COUNT(*) FROM sys.columns c WHERE c.object_id = t.object_id) AS column_count
FROM sys.tables t
WHERE t.schema_id = SCHEMA_ID('core')
ORDER BY t.name;
GO
SELECT type_desc, COUNT(*) AS how_many
FROM sys.objects
WHERE schema_id = SCHEMA_ID('core') AND type IN ('PK', 'F', 'UQ', 'C')
GROUP BY type_desc
ORDER BY type_desc;
GO
SELECT error_type_id, error_name FROM core.error_type ORDER BY error_type_id;
GO