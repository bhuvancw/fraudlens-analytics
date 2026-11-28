USE FraudLens;
GO
SELECT MIN(row_id) AS first_user_row, MAX(row_id) AS last_user_row, COUNT(*) AS users
FROM stg.users_raw;
GO
SELECT MIN(row_id) AS first_txn_row, MAX(row_id) AS last_txn_row, COUNT(*) AS txns
FROM stg.card_transaction_raw;
GO
-- These are the data rows we saw earlier in the file at lines 12, 13, 14 and 23
SELECT row_id, txn_year, txn_month, txn_day, txn_time, amount, use_chip, errors
FROM stg.card_transaction_raw
WHERE row_id IN (11, 12, 13, 22)
ORDER BY row_id;
GO
-- Is the user ID really the row position? Num Credit Cards must equal the card count.
SELECT COUNT(*) AS users_matching_card_count
FROM stg.users_raw u
JOIN (SELECT TRY_CAST(user_id AS INT) AS uid, COUNT(*) AS n
      FROM stg.cards_raw
      GROUP BY TRY_CAST(user_id AS INT)) c
  ON c.uid = u.row_id
WHERE TRY_CAST(u.num_credit_cards AS INT) = c.n;
GO