-- FraudLens: stg schema (raw landing tables, everything as text)

USE FraudLens;
GO

IF OBJECT_ID('stg.users_raw', 'U') IS NULL
CREATE TABLE stg.users_raw (
    person                    VARCHAR(100) NULL,
    current_age               VARCHAR(10)  NULL,
    retirement_age            VARCHAR(10)  NULL,
    birth_year                VARCHAR(10)  NULL,
    birth_month               VARCHAR(10)  NULL,
    gender                    VARCHAR(20)  NULL,
    address                   VARCHAR(200) NULL,
    apartment                 VARCHAR(20)  NULL,
    city                      VARCHAR(100) NULL,
    state                     VARCHAR(50)  NULL,
    zipcode                   VARCHAR(20)  NULL,
    latitude                  VARCHAR(20)  NULL,
    longitude                 VARCHAR(20)  NULL,
    per_capita_income_zipcode VARCHAR(30)  NULL,
    yearly_income_person      VARCHAR(30)  NULL,
    total_debt                VARCHAR(30)  NULL,
    fico_score                VARCHAR(10)  NULL,
    num_credit_cards          VARCHAR(10)  NULL,
    source_file VARCHAR(200) NOT NULL CONSTRAINT DF_users_raw_file DEFAULT 'sd254_users.csv',
    loaded_at   DATETIME2(0) NOT NULL CONSTRAINT DF_users_raw_loaded DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('stg.cards_raw', 'U') IS NULL
CREATE TABLE stg.cards_raw (
    user_id               VARCHAR(10) NULL,
    card_index            VARCHAR(10) NULL,
    card_brand            VARCHAR(30) NULL,
    card_type             VARCHAR(30) NULL,
    card_number           VARCHAR(30) NULL,
    expires               VARCHAR(10) NULL,
    cvv                   VARCHAR(10) NULL,
    has_chip              VARCHAR(10) NULL,
    cards_issued          VARCHAR(10) NULL,
    credit_limit          VARCHAR(30) NULL,
    acct_open_date        VARCHAR(10) NULL,
    year_pin_last_changed VARCHAR(10) NULL,
    card_on_dark_web      VARCHAR(10) NULL,
    source_file VARCHAR(200) NOT NULL CONSTRAINT DF_cards_raw_file DEFAULT 'sd254_cards.csv',
    loaded_at   DATETIME2(0) NOT NULL CONSTRAINT DF_cards_raw_loaded DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('stg.card_transaction_raw', 'U') IS NULL
CREATE TABLE stg.card_transaction_raw (
    user_id        VARCHAR(10)  NULL,
    card_index     VARCHAR(10)  NULL,
    txn_year       VARCHAR(10)  NULL,
    txn_month      VARCHAR(10)  NULL,
    txn_day        VARCHAR(10)  NULL,
    txn_time       VARCHAR(10)  NULL,
    amount         VARCHAR(20)  NULL,
    use_chip       VARCHAR(30)  NULL,
    merchant_name  VARCHAR(30)  NULL,
    merchant_city  VARCHAR(200) NULL,
    merchant_state VARCHAR(50)  NULL,
    zip            VARCHAR(20)  NULL,
    mcc            VARCHAR(10)  NULL,
    errors         VARCHAR(200) NULL,
    is_fraud       VARCHAR(10)  NULL,
    source_file VARCHAR(200) NOT NULL CONSTRAINT DF_txn_raw_file DEFAULT 'card_transaction.v1.csv',
    loaded_at   DATETIME2(0) NOT NULL CONSTRAINT DF_txn_raw_loaded DEFAULT SYSUTCDATETIME()
);
GO

IF OBJECT_ID('stg.v_users_load', 'V') IS NULL
EXEC('CREATE VIEW stg.v_users_load AS
      SELECT person, current_age, retirement_age, birth_year, birth_month, gender, address, apartment,
             city, state, zipcode, latitude, longitude, per_capita_income_zipcode,
             yearly_income_person, total_debt, fico_score, num_credit_cards
      FROM stg.users_raw');
GO

IF OBJECT_ID('stg.v_cards_load', 'V') IS NULL
EXEC('CREATE VIEW stg.v_cards_load AS
      SELECT user_id, card_index, card_brand, card_type, card_number, expires, cvv, has_chip,
             cards_issued, credit_limit, acct_open_date, year_pin_last_changed, card_on_dark_web
      FROM stg.cards_raw');
GO

IF OBJECT_ID('stg.v_card_transaction_load', 'V') IS NULL
EXEC('CREATE VIEW stg.v_card_transaction_load AS
      SELECT user_id, card_index, txn_year, txn_month, txn_day, txn_time, amount, use_chip,
             merchant_name, merchant_city, merchant_state, zip, mcc, errors, is_fraud
      FROM stg.card_transaction_raw');
GO

IF OBJECT_ID('stg.load_log', 'U') IS NULL
CREATE TABLE stg.load_log (
    load_id     INT IDENTITY(1,1) NOT NULL,
    table_name  VARCHAR(100) NOT NULL,
    source_file VARCHAR(200) NOT NULL,
    rows_loaded BIGINT       NOT NULL,
    loaded_at   DATETIME2(0) NOT NULL CONSTRAINT DF_load_log_loaded DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_load_log PRIMARY KEY (load_id)
);
GO