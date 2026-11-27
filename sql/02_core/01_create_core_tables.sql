-- FraudLens: core schema (normalised model)

USE FraudLens;
GO

IF OBJECT_ID('core.merchant_category', 'U') IS NULL
CREATE TABLE core.merchant_category (
    mcc INT NOT NULL,
    CONSTRAINT PK_merchant_category PRIMARY KEY (mcc)
);
GO

IF OBJECT_ID('core.merchant', 'U') IS NULL
CREATE TABLE core.merchant (
    merchant_id BIGINT NOT NULL,
    CONSTRAINT PK_merchant PRIMARY KEY (merchant_id)
);
GO

IF OBJECT_ID('core.location', 'U') IS NULL
CREATE TABLE core.location (
    location_id       INT IDENTITY(1,1) NOT NULL,
    location_type     VARCHAR(7)    NOT NULL,
    city              VARCHAR(100)  NOT NULL,
    state_code        CHAR(2)       NULL,
    country           VARCHAR(50)   NULL,
    zip_code          CHAR(5)       NULL,
    per_capita_income DECIMAL(12,2) NULL,
    CONSTRAINT PK_location PRIMARY KEY (location_id),
    CONSTRAINT CK_location_type CHECK (
           (location_type = 'US'      AND state_code IS NOT NULL AND zip_code IS NOT NULL AND country IS NULL)
        OR (location_type = 'FOREIGN' AND state_code IS NULL AND zip_code IS NULL AND country IS NOT NULL)
        OR (location_type = 'ONLINE'  AND state_code IS NULL AND zip_code IS NULL AND country IS NULL)
    )
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_location_zip' AND object_id = OBJECT_ID('core.location'))
CREATE UNIQUE INDEX UX_location_zip ON core.location (zip_code) WHERE zip_code IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_location_no_zip' AND object_id = OBJECT_ID('core.location'))
CREATE UNIQUE INDEX UX_location_no_zip ON core.location (location_type, city, country) WHERE zip_code IS NULL;
GO

IF OBJECT_ID('core.customer', 'U') IS NULL
CREATE TABLE core.customer (
    customer_id      INT           NOT NULL,
    home_location_id INT           NOT NULL,
    birth_year       SMALLINT      NOT NULL,
    birth_month      TINYINT       NOT NULL,
    gender           VARCHAR(10)   NULL,
    retirement_age   TINYINT       NOT NULL,
    latitude         DECIMAL(9,6)  NULL,
    longitude        DECIMAL(9,6)  NULL,
    yearly_income    DECIMAL(12,2) NULL,
    total_debt       DECIMAL(12,2) NULL,
    fico_score       SMALLINT      NOT NULL,
    CONSTRAINT PK_customer PRIMARY KEY (customer_id),
    CONSTRAINT FK_customer_location FOREIGN KEY (home_location_id) REFERENCES core.location (location_id),
    CONSTRAINT CK_customer_birth_month CHECK (birth_month BETWEEN 1 AND 12),
    CONSTRAINT CK_customer_fico CHECK (fico_score BETWEEN 300 AND 850)
);
GO

IF OBJECT_ID('core.card', 'U') IS NULL
CREATE TABLE core.card (
    customer_id           INT           NOT NULL,
    card_index            TINYINT       NOT NULL,
    card_brand            VARCHAR(20)   NULL,
    card_type             VARCHAR(30)   NULL,
    expires               DATE          NULL,
    has_chip              BIT           NULL,
    cards_issued          TINYINT       NOT NULL,
    credit_limit          DECIMAL(12,2) NULL,
    account_open_date     DATE          NULL,
    pin_last_changed_year SMALLINT      NOT NULL,
    on_dark_web           BIT           NULL,
    CONSTRAINT PK_card PRIMARY KEY (customer_id, card_index),
    CONSTRAINT FK_card_customer FOREIGN KEY (customer_id) REFERENCES core.customer (customer_id)
);
GO

IF OBJECT_ID('core.error_type', 'U') IS NULL
CREATE TABLE core.error_type (
    error_type_id TINYINT IDENTITY(1,1) NOT NULL,
    error_name    VARCHAR(30) NOT NULL,
    CONSTRAINT PK_error_type PRIMARY KEY (error_type_id),
    CONSTRAINT UQ_error_type_name UNIQUE (error_name)
);
GO

INSERT INTO core.error_type (error_name)
SELECT v.error_name
FROM (VALUES ('Bad CVV'), ('Bad Card Number'), ('Bad Expiration'), ('Bad PIN'),
             ('Bad Zipcode'), ('Insufficient Balance'), ('Technical Glitch')) AS v (error_name)
WHERE NOT EXISTS (SELECT 1 FROM core.error_type e WHERE e.error_name = v.error_name);
GO

IF OBJECT_ID('core.card_transaction', 'U') IS NULL
CREATE TABLE core.card_transaction (
    transaction_id       BIGINT IDENTITY(1,1) NOT NULL,
    customer_id          INT           NOT NULL,
    card_index           TINYINT       NOT NULL,
    merchant_id          BIGINT        NOT NULL,
    location_id          INT           NOT NULL,
    mcc                  INT           NOT NULL,
    transaction_datetime DATETIME2(0)  NOT NULL,
    amount               DECIMAL(10,2) NOT NULL,
    channel              VARCHAR(10)   NOT NULL,
    is_fraud             BIT           NOT NULL,
    CONSTRAINT PK_card_transaction PRIMARY KEY (transaction_id),
    CONSTRAINT FK_card_transaction_card FOREIGN KEY (customer_id, card_index)
        REFERENCES core.card (customer_id, card_index),
    CONSTRAINT FK_card_transaction_merchant FOREIGN KEY (merchant_id) REFERENCES core.merchant (merchant_id),
    CONSTRAINT FK_card_transaction_location FOREIGN KEY (location_id) REFERENCES core.location (location_id),
    CONSTRAINT FK_card_transaction_category FOREIGN KEY (mcc) REFERENCES core.merchant_category (mcc),
    CONSTRAINT CK_card_transaction_channel CHECK (channel IN ('Swipe', 'Chip', 'Online'))
);
GO

IF OBJECT_ID('core.transaction_error', 'U') IS NULL
CREATE TABLE core.transaction_error (
    transaction_id BIGINT  NOT NULL,
    error_type_id  TINYINT NOT NULL,
    CONSTRAINT PK_transaction_error PRIMARY KEY (transaction_id, error_type_id),
    CONSTRAINT FK_transaction_error_transaction FOREIGN KEY (transaction_id)
        REFERENCES core.card_transaction (transaction_id),
    CONSTRAINT FK_transaction_error_type FOREIGN KEY (error_type_id)
        REFERENCES core.error_type (error_type_id)
);
GO