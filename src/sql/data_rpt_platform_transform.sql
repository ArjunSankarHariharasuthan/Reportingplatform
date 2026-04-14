-- Table: reporting_platform.address

-- DROP TABLE IF EXISTS "data_rpt_plaform".address;

CREATE TABLE IF NOT EXISTS "data_rpt_plaform".address
(
    adrs_i integer NOT NULL,
    unit_n character varying(50) COLLATE pg_catalog."default",
    st_n character varying(50) COLLATE pg_catalog."default" NOT NULL,
    st_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    surb_n character varying(50) COLLATE pg_catalog."default" NOT NULL,
    pst1_c character(4) COLLATE pg_catalog."default" NOT NULL,
    
    stat_c character(3) COLLATE pg_catalog."default" NOT NULL,
    stat_n character varying(50) COLLATE pg_catalog."default" NOT NULL ,
     full_addr_x character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT addr_pkey PRIMARY KEY (adrs_i)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".customer
    OWNER to postgres;

--CUSTOMER TABLE

CREATE TABLE IF NOT EXISTS "data_rpt_plaform".customer
(
    customer_id integer NOT NULL,
    source_customer_num integer,
    customer_name character varying(255) NOT NULL,
    customer_dob date,
    customer_organisation_flag character(10),
    customer_start_date date,
    customer_email_val character(80),
    customer_contact_number character varying(50),
    CONSTRAINT customer_pkey PRIMARY KEY (customer_id)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".customer
    OWNER TO postgres;

--SPONSOR TABLE
CREATE TABLE IF NOT EXISTS "data_rpt_plaform".sponsor
(
    sponsor_id              integer NOT NULL,
    source_customer_num     integer,               -- matches customer table datatype
    sponsor_name            character varying(255) NOT NULL,
    sponsor_dob             date,
    sponsor_start_dt        date,
    sponsor_email_val       character(80),
    sponsor_abn_val         character varying(50),
    sponsor_type_cd         integer NOT NULL,
    CONSTRAINT sponsor_pkey PRIMARY KEY (sponsor_id)  

	ALTER TABLE "data_rpt_plaform".sponsor
    ADD COLUMN sponsor_type_cd integer NOT NULL;

	ALTER TABLE "data_rpt_plaform".sponsor
    ADD CONSTRAINT fk_sponsor_type
    FOREIGN KEY (sponsor_type_cd)
    REFERENCES "data_rpt_plaform".sponsor_type(sponsor_type_cd);
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".sponsor
    OWNER TO postgres;

--ACCOUNT TABLE
CREATE TABLE IF NOT EXISTS "data_rpt_plaform".account
(
    account_id             integer NOT NULL,
    source_customer_num    integer,
    account_active_flag    character(10),
    account_created_dttm   timestamp,
    customer_id            integer NOT NULL,
    sponsor_id             integer,
	--sponsor_holder_type_cd int
    account_name           character varying(255),

    CONSTRAINT account_pkey PRIMARY KEY (account_id),

	ALTER TABLE "data_rpt_plaform".account
    ADD COLUMN sponsor_holder_type_cd integer NOT NULL;

    CONSTRAINT fk_account_customer
        FOREIGN KEY (customer_id)
        REFERENCES "data_rpt_plaform".customer(customer_id),

    CONSTRAINT fk_account_sponsor
        FOREIGN KEY (sponsor_id)
        REFERENCES "data_rpt_plaform".sponsor(sponsor_id)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".account
    OWNER TO postgres;

--SPONSOR_TYPE TABLE
CREATE TABLE IF NOT EXISTS "data_rpt_plaform".sponsor_type
(
    sponsor_type_cd     integer NOT NULL,
    sponsor_type_name   character varying(255),
    sponsor_type_desc   character varying(500),

    CONSTRAINT sponsor_type_pkey PRIMARY KEY (sponsor_type_cd)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".sponsor_type
    OWNER TO postgres;

--ACCOUNT_HOLDER_TYPE
CREATE TABLE IF NOT EXISTS "data_rpt_plaform".account_holder_type
(
    account_holder_type_cd     integer NOT NULL,
    account_holder_type_name   character varying(255),
    account_holder_type_desc   character varying(500),

    CONSTRAINT account_holder_type_pkey PRIMARY KEY (account_holder_type_cd)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".account_holder_type
    OWNER TO postgres;

--TRANSACTION_EVENT_TYPE
CREATE TABLE IF NOT EXISTS "data_rpt_plaform".transaction_event_type
(
    transaction_event_type_id     integer NOT NULL,
    transaction_event_type_name   character varying(255),
    transaction_event_type_desc   character varying(500),

    CONSTRAINT transaction_event_type_pkey 
    PRIMARY KEY (transaction_event_type_id)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".transaction_event_type
    OWNER TO postgres;

--CUSTOMER_ADDRESS TABLE
CREATE TABLE IF NOT EXISTS "data_rpt_plaform".customer_address
(
    customer_id                 integer NOT NULL,
    customer_address_eff_date   date    NOT NULL,
    customer_address_end_date   date NOT NULL,
    adrs_i                      integer NOT NULL,

    CONSTRAINT customer_address_pkey 
        PRIMARY KEY (customer_id, customer_address_eff_date),

    CONSTRAINT fk_customer_address_customer
        FOREIGN KEY (customer_id)
        REFERENCES "data_rpt_plaform".customer(customer_id),

    CONSTRAINT fk_customer_address_address
        FOREIGN KEY (adrs_i)
        REFERENCES "data_rpt_plaform".address(adrs_i)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".customer_address
    OWNER TO postgres;

--TRANSACTION_EVENT TABLE
CREATE TABLE IF NOT EXISTS "data_rpt_plaform".transaction_event
(
    transaction_event_id        integer NOT NULL,
    sponsor_id                  integer NOT NULL,
    event_created_dttm          timestamp NOT NULL,
    customer_id                 integer NOT NULL,
    from_account_id             integer,
    to_account_id               integer,
    transaction_event_type_cd   integer NOT NULL,
    transaction_amount          numeric(18,2),

    CONSTRAINT transaction_event_pkey 
        PRIMARY KEY (transaction_event_id),

    CONSTRAINT fk_te_sponsor
        FOREIGN KEY (sponsor_id)
        REFERENCES "data_rpt_plaform".sponsor(sponsor_id),

    CONSTRAINT fk_te_customer
        FOREIGN KEY (customer_id)
        REFERENCES "data_rpt_plaform".customer(customer_id),

    CONSTRAINT fk_te_from_account
        FOREIGN KEY (from_account_id)
        REFERENCES "data_rpt_plaform".account(account_id),

    CONSTRAINT fk_te_to_account
        FOREIGN KEY (to_account_id)
        REFERENCES "data_rpt_plaform".account(account_id),

    CONSTRAINT fk_te_event_type
        FOREIGN KEY (transaction_event_type_cd)
        REFERENCES "data_rpt_plaform".transaction_event_type(transaction_event_type_id)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS "data_rpt_plaform".transaction_event
    OWNER TO postgres;

SELECT * FROM "data_rpt_plaform".account

ALTER TABLE "data_rpt_plaform".account
DROP COLUMN sponsor_holder_type_cd;

ALTER TABLE "data_rpt_plaform".account
ADD COLUMN account_holder_type_cd integer;
ALTER TABLE "data_rpt_plaform".account
ADD CONSTRAINT fk_account_holder_type
    FOREIGN KEY (account_holder_type_cd)
    REFERENCES "data_rpt_plaform".account_holder_type(account_holder_type_cd);


SELECT * FROM "data_rpt_plaform".transaction_event_type
