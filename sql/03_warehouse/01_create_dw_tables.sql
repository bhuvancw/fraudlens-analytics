-- FraudLens: dw schema (star schema)

USE FraudLens;
GO

IF OBJECT_ID('dw.dim_date', 'U') IS NULL
CREATE TABLE dw.dim_date (
    date_key         INT        NOT NULL,
    full_date        DATE       NOT NULL,
    calendar_year    SMALLINT   NOT NULL,
    calendar_quarter TINYINT    NOT NULL,
    month_number     TINYINT    NOT NULL,
    month_name       VARCHAR(9) NOT NULL,
    year_month       CHAR(7)    NOT NULL,
    day_of_month     TINYINT    NOT NULL,
    day_of_week      TINYINT    NOT NULL,
    day_name         VARCHAR(9) NOT NULL,
    is_weekend       BIT        NOT NULL,
    is_partial_year  BIT        NOT NULL CONSTRAINT DF_dim_date_partial DEFAULT 0,
    CONSTRAINT PK_dim_date PRIMARY KEY (date_key),
    CONSTRAINT UQ_dim_date_full_date UNIQUE (full_date)
);
GO

IF OBJECT_ID('dw.dim_time', 'U') IS NULL
CREATE TABLE dw.dim_time (
    time_key       SMALLINT    NOT NULL,
    hour_of_day    TINYINT     NOT NULL,
    minute_of_hour TINYINT     NOT NULL,
    day_part       VARCHAR(10) NOT NULL,
    CONSTRAINT PK_dim_time PRIMARY KEY (time_key)
);
GO

IF OBJECT_ID('dw.dim_customer', 'U') IS NULL
CREATE TABLE dw.dim_customer (
    customer_key   INT IDENTITY(1,1) NOT NULL,
    customer_id    INT           NOT NULL,
    birth_year     SMALLINT      NULL,
    age_band       VARCHAR(10)   NULL,
    gender         VARCHAR(10)   NULL,
    retirement_age TINYINT       NULL,
    yearly_income  DECIMAL(12,2) NULL,
    total_debt     DECIMAL(12,2) NULL,
    fico_score     SMALLINT      NULL,
    fico_band      VARCHAR(15)   NULL,
    risk_segment   VARCHAR(20)   NOT NULL CONSTRAINT DF_dim_customer_segment DEFAULT 'Unscored',
    effective_from DATE          NOT NULL CONSTRAINT DF_dim_customer_from DEFAULT '1900-01-01',
    effective_to   DATE          NOT NULL CONSTRAINT DF_dim_customer_to DEFAULT '9999-12-31',
    is_current     BIT           NOT NULL CONSTRAINT DF_dim_customer_current DEFAULT 1,
    CONSTRAINT PK_dim_customer PRIMARY KEY (customer_key),
    CONSTRAINT UQ_dim_customer_version UNIQUE (customer_id, effective_from)
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_dim_customer_current' AND object_id = OBJECT_ID('dw.dim_customer'))
CREATE UNIQUE INDEX UX_dim_customer_current ON dw.dim_customer (customer_id) WHERE is_current = 1;
GO

IF OBJECT_ID('dw.dim_card', 'U') IS NULL
CREATE TABLE dw.dim_card (
    card_key              INT IDENTITY(1,1) NOT NULL,
    customer_id           INT           NOT NULL,
    card_index            TINYINT       NOT NULL,
    card_brand            VARCHAR(20)   NULL,
    card_type             VARCHAR(30)   NULL,
    has_chip              BIT           NULL,
    credit_limit          DECIMAL(12,2) NULL,
    credit_limit_band     VARCHAR(15)   NULL,
    account_open_year     SMALLINT      NULL,
    cards_issued          TINYINT       NULL,
    pin_last_changed_year SMALLINT      NULL,
    on_dark_web           BIT           NULL,
    CONSTRAINT PK_dim_card PRIMARY KEY (card_key),
    CONSTRAINT UQ_dim_card_business_key UNIQUE (customer_id, card_index)
);
GO

IF OBJECT_ID('dw.dim_merchant', 'U') IS NULL
CREATE TABLE dw.dim_merchant (
    merchant_key   INT IDENTITY(1,1) NOT NULL,
    merchant_id    BIGINT      NOT NULL,
    location_count INT         NULL,
    merchant_scope VARCHAR(15) NULL,
    CONSTRAINT PK_dim_merchant PRIMARY KEY (merchant_key),
    CONSTRAINT UQ_dim_merchant_id UNIQUE (merchant_id)
);
GO

IF OBJECT_ID('dw.dim_geography', 'U') IS NULL
CREATE TABLE dw.dim_geography (
    geography_key     INT IDENTITY(1,1) NOT NULL,
    location_id       INT           NOT NULL,
    location_type     VARCHAR(10)   NOT NULL,
    city              VARCHAR(100)  NULL,
    state_code        CHAR(2)       NULL,
    country           VARCHAR(50)   NULL,
    zip_code          CHAR(5)       NULL,
    per_capita_income DECIMAL(12,2) NULL,
    CONSTRAINT PK_dim_geography PRIMARY KEY (geography_key),
    CONSTRAINT UQ_dim_geography_location UNIQUE (location_id)
);
GO

IF OBJECT_ID('dw.dim_mcc', 'U') IS NULL
CREATE TABLE dw.dim_mcc (
    mcc_key         INT IDENTITY(1,1) NOT NULL,
    mcc             INT           NOT NULL,
    mcc_description VARCHAR(200)  NULL,
    CONSTRAINT PK_dim_mcc PRIMARY KEY (mcc_key),
    CONSTRAINT UQ_dim_mcc_code UNIQUE (mcc)
);
GO

IF OBJECT_ID('dw.dim_transaction_profile', 'U') IS NULL
CREATE TABLE dw.dim_transaction_profile (
    profile_key           INT IDENTITY(1,1) NOT NULL,
    channel               VARCHAR(10) NOT NULL,
    is_refund             BIT         NOT NULL,
    channel_city_mismatch BIT         NOT NULL,
    home_vs_merchant      VARCHAR(15) NOT NULL,
    CONSTRAINT PK_dim_transaction_profile PRIMARY KEY (profile_key),
    CONSTRAINT UQ_dim_transaction_profile UNIQUE (channel, is_refund, channel_city_mismatch, home_vs_merchant),
    CONSTRAINT CK_profile_channel CHECK (channel IN ('Swipe', 'Chip', 'Online', 'Unknown')),
    CONSTRAINT CK_profile_home_vs_merchant CHECK (
        home_vs_merchant IN ('Online', 'Same state', 'Other US state', 'International', 'Unknown'))
);
GO

IF OBJECT_ID('dw.dim_error_combination', 'U') IS NULL
CREATE TABLE dw.dim_error_combination (
    error_combination_key    INT IDENTITY(1,1) NOT NULL,
    error_text               VARCHAR(100) NOT NULL,
    error_count              TINYINT      NOT NULL,
    has_bad_cvv              BIT          NOT NULL,
    has_bad_card_number      BIT          NOT NULL,
    has_bad_expiration       BIT          NOT NULL,
    has_bad_pin              BIT          NOT NULL,
    has_bad_zipcode          BIT          NOT NULL,
    has_insufficient_balance BIT          NOT NULL,
    has_technical_glitch     BIT          NOT NULL,
    CONSTRAINT PK_dim_error_combination PRIMARY KEY (error_combination_key),
    CONSTRAINT UQ_dim_error_combination_text UNIQUE (error_text)
);
GO

IF OBJECT_ID('dw.fact_transaction', 'U') IS NULL
CREATE TABLE dw.fact_transaction (
    transaction_id         BIGINT        NOT NULL,
    date_key               INT           NOT NULL,
    time_key               SMALLINT      NOT NULL,
    customer_key           INT           NOT NULL,
    card_key               INT           NOT NULL,
    merchant_key           INT           NOT NULL,
    merchant_geography_key INT           NOT NULL,
    home_geography_key     INT           NOT NULL,
    mcc_key                INT           NOT NULL,
    profile_key            INT           NOT NULL,
    error_combination_key  INT           NOT NULL,
    amount                 DECIMAL(10,2) NOT NULL,
    fraud_flag             TINYINT       NOT NULL,
    fraud_amount           DECIMAL(10,2) NOT NULL,
    error_count            TINYINT       NOT NULL,
    CONSTRAINT PK_fact_transaction PRIMARY KEY NONCLUSTERED (transaction_id),
    CONSTRAINT CK_fact_transaction_fraud_flag CHECK (fraud_flag IN (0, 1))
);
GO

IF OBJECT_ID('dw.fact_customer_month', 'U') IS NULL
CREATE TABLE dw.fact_customer_month (
    month_end_date_key INT           NOT NULL,
    customer_key       INT           NOT NULL,
    transaction_count  INT           NOT NULL,
    spend              DECIMAL(14,2) NOT NULL,
    fraud_count        INT           NOT NULL,
    fraud_amount       DECIMAL(14,2) NOT NULL,
    refund_amount      DECIMAL(14,2) NOT NULL,
    error_count        INT           NOT NULL,
    credit_limit_total DECIMAL(14,2) NULL,
    risk_score         DECIMAL(6,2)  NULL,
    CONSTRAINT PK_fact_customer_month PRIMARY KEY (month_end_date_key, customer_key)
);
GO

SET IDENTITY_INSERT dw.dim_customer ON;
INSERT INTO dw.dim_customer (customer_key, customer_id, risk_segment)
SELECT -1, -1, 'Unknown' WHERE NOT EXISTS (SELECT 1 FROM dw.dim_customer WHERE customer_key = -1);
SET IDENTITY_INSERT dw.dim_customer OFF;
GO

SET IDENTITY_INSERT dw.dim_card ON;
INSERT INTO dw.dim_card (card_key, customer_id, card_index)
SELECT -1, -1, 0 WHERE NOT EXISTS (SELECT 1 FROM dw.dim_card WHERE card_key = -1);
SET IDENTITY_INSERT dw.dim_card OFF;
GO

SET IDENTITY_INSERT dw.dim_merchant ON;
INSERT INTO dw.dim_merchant (merchant_key, merchant_id, merchant_scope)
SELECT -1, -1, 'Unknown' WHERE NOT EXISTS (SELECT 1 FROM dw.dim_merchant WHERE merchant_key = -1);
SET IDENTITY_INSERT dw.dim_merchant OFF;
GO

SET IDENTITY_INSERT dw.dim_geography ON;
INSERT INTO dw.dim_geography (geography_key, location_id, location_type)
SELECT -1, -1, 'UNKNOWN' WHERE NOT EXISTS (SELECT 1 FROM dw.dim_geography WHERE geography_key = -1);
SET IDENTITY_INSERT dw.dim_geography OFF;
GO

SET IDENTITY_INSERT dw.dim_mcc ON;
INSERT INTO dw.dim_mcc (mcc_key, mcc)
SELECT -1, -1 WHERE NOT EXISTS (SELECT 1 FROM dw.dim_mcc WHERE mcc_key = -1);
SET IDENTITY_INSERT dw.dim_mcc OFF;
GO

SET IDENTITY_INSERT dw.dim_transaction_profile ON;
INSERT INTO dw.dim_transaction_profile (profile_key, channel, is_refund, channel_city_mismatch, home_vs_merchant)
SELECT -1, 'Unknown', 0, 0, 'Unknown' WHERE NOT EXISTS (SELECT 1 FROM dw.dim_transaction_profile WHERE profile_key = -1);
SET IDENTITY_INSERT dw.dim_transaction_profile OFF;
GO

SET IDENTITY_INSERT dw.dim_error_combination ON;
INSERT INTO dw.dim_error_combination
    (error_combination_key, error_text, error_count, has_bad_cvv, has_bad_card_number, has_bad_expiration,
     has_bad_pin, has_bad_zipcode, has_insufficient_balance, has_technical_glitch)
SELECT -1, 'Unknown', 0, 0, 0, 0, 0, 0, 0, 0
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_error_combination WHERE error_combination_key = -1);
SET IDENTITY_INSERT dw.dim_error_combination OFF;
GO