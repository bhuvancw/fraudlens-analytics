# Source Data Dictionary

Source: IBM TabFormer synthetic credit card transactions. Files are in `data/raw/` (not committed). Checksums are in `source_manifest.txt`. All figures come from notebook `01_data_understanding.ipynb`.

## card_transaction.v1.csv

24,386,900 rows, 15 columns, years 1991 to 2020. No transaction ID column.

| Column | Observed format | Notes and handling |
|---|---|---|
| User | integer 0 to 1999 | Row position in the users file. Links to users. |
| Card | integer card index | With User, links to cards (User, CARD INDEX). All 6,139 pairs used exist in cards. |
| Year, Month, Day | integers | Always form a valid date. 2020 is a partial year. |
| Time | text HH:MM | Hours 00 to 23. Combine with the date into one timestamp. |
| Amount | text, `$12.34` or `$-99.00` | Range -500.00 to 12,390.50. 1,244,689 negative values (5.1%). Strip `$`, cast to decimal. |
| Use Chip | Swipe / Chip / Online Transaction | 15,386,082 / 6,287,598 / 2,713,220 rows. |
| Merchant Name | large signed integer | Anonymised merchant ID. No merchant master table exists. |
| Merchant City | text | `ONLINE` for online. IBM original has a leading space on some rows, so trim. 2,720,821 rows are ONLINE. |
| Merchant State | text | 2-character US code (21,508,765), blank for online (2,720,821), country name for foreign merchants (157,314 rows, 171 distinct). |
| Zip | text like `91750.0` | Blank on 2,878,135 rows. 1,555,116 values lost leading zeros. Strip `.0`, left-pad to 5 digits. |
| MCC | integer code | 109 distinct codes. |
| Errors? | text | Blank on 23,998,469 rows. Otherwise a comma-separated list with a trailing comma. 24 distinct strings, 7 base types: Bad CVV, Bad Card Number, Bad Expiration, Bad PIN, Bad Zipcode, Insufficient Balance, Technical Glitch. Split into a separate table (1NF). |
| Is Fraud? | Yes / No | 29,757 Yes (about 0.122%). |

## sd254_users.csv

2,000 rows, 18 columns. No ID column: user ID is the row position (0 to 1999).

| Column | Observed type | Notes and handling |
|---|---|---|
| Person | text | Not unique (7 duplicates). Personal data: do not carry into the warehouse. |
| Current Age, Retirement Age, Birth Year, Birth Month | integer | Descriptive use only, not in risk scoring. |
| Gender | text | Descriptive use only, not in risk scoring. |
| Address, Apartment | text, float | Personal data. Drop. Apartment appears mostly empty (to verify). |
| City, State | text | Home location. |
| Zipcode | integer | Leading zeros lost. Treat as text, pad to 5 digits. |
| Latitude, Longitude | float | Home coordinates. |
| Per Capita Income - Zipcode, Yearly Income - Person, Total Debt | text | Contain currency formatting. Cast to decimal. |
| FICO Score | integer | Input to risk segmentation. |
| Num Credit Cards | integer | Matches the card count in cards for all 2,000 users. |

## sd254_cards.csv

6,146 rows, 13 columns. (User, CARD INDEX) is unique. 7 cards have no transactions.

| Column | Observed type | Notes and handling |
|---|---|---|
| User, CARD INDEX | integer | Composite key. |
| Card Brand, Card Type | text | Dimension attributes. |
| Card Number, CVV | integer | Sensitive. Hash or drop before the warehouse. |
| Expires, Acct Open Date | text | Month and year as text, to be parsed. |
| Has Chip, Card on Dark Web | text | Yes/No flags. |
| Cards Issued, Year PIN last Changed | integer | |
| Credit Limit | text | Currency formatting. Cast to decimal. |

## Known data-quality issues

1. IBM original has a leading space before ONLINE in Merchant City.
2. Errors? is multi-valued with trailing commas.
3. Zip and Zipcode lose leading zeros.
4. 7,601 rows have city ONLINE but Use Chip = Chip Transaction.
5. 1,125 fraud rows have negative amounts.
6. 2020 is a partial year.
7. The data is synthetic: fraud labels come from a generator, and the chip fraud rate exceeds the swipe rate.