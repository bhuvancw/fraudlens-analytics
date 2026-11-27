# Physical Data Model (core schema)

Implements the logical model in SQL Server 2022. Script: `sql/02_core/01_create_core_tables.sql`. Check script: `sql/02_core/02_verify_core_tables.sql`.

Result of the check: 8 tables, 8 primary keys, 8 foreign keys, 4 check constraints, 1 unique constraint, plus 2 filtered unique indexes on `core.location`.

## Naming

The logical `TRANSACTION` table is `core.card_transaction` in SQL Server, because `TRANSACTION` is a reserved T-SQL keyword. All other names match the logical model.

## Data type decisions

| Column(s) | Type | Reason |
|---|---|---|
| amount, income, debt, credit limit | DECIMAL | Exact arithmetic. FLOAT stores money approximately, so sums drift. |
| merchant_id | BIGINT | Observed values are far outside the INT range. |
| transaction_id | BIGINT IDENTITY | About 24 million rows now, and the key is generated. |
| zip_code | CHAR(5) | Zips are fixed-width text. Storing them as numbers is what lost the leading zeros in the source. |
| transaction_datetime | DATETIME2(0) | Source times are to the minute, so fractional seconds are not needed. |
| Yes/No flags | BIT | One bit instead of text. |
| birth_month, card_index, retirement_age | TINYINT | Small known ranges. |
| birth_year, fico_score, pin_last_changed_year | SMALLINT | Small known ranges. |

## Constraints

| Constraint | Purpose |
|---|---|
| Primary keys on every table | Uniqueness. card uses (customer_id, card_index). transaction_error uses (transaction_id, error_type_id). |
| 8 foreign keys | The database rejects a transaction for a card, merchant, location or category that does not exist. |
| CK_location_type | A US location must have a state and a zip and no country. A foreign location must have a country and no state or zip. An online location has none of the three. |
| CK_customer_birth_month, CK_customer_fico | Months 1 to 12 and FICO 300 to 850. |
| CK_card_transaction_channel | Channel is Swipe, Chip or Online. |
| UQ_error_type_name | Error names are unique. |
| UX_location_zip (filtered unique index) | A zip identifies one US location. Filtered, so the many rows with no zip can coexist. |
| UX_location_no_zip (filtered unique index) | Foreign and online locations are identified by type, city and country. |

## NOT NULL decisions

Every column in `card_transaction` is NOT NULL, because notebook 01 found no blanks in any of the source columns behind it. Some customer and card columns are nullable for now. We only know their types, so they will be tightened after the staging data is profiled.

## Deferred on purpose

- **Extra indexes.** Beyond the primary keys, nonclustered indexes are created after the bulk load. Loading into a table that already has many indexes is slower, and we want to see real query patterns first.
- **DEFAULT constraints.** These appear in the staging schema (load id, load timestamp), where they record how each row arrived.
- **Columnstore indexes.** Planned for the warehouse fact table in the dw schema.

## Storage

The database uses SIMPLE recovery, because all data can be reloaded from the source files. Data files are in the SQL Server default location. Sizes will be measured after the first full load, not estimated.