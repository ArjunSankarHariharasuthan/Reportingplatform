DROP TABLE IF EXISTS public.CUSTOMER

CREATE TABLE CUSTOMER (
    CustomerId  PRIMARY KEY,
	Name VARCHAR(100),
	DOB DATE
);

DROP TABLE IF EXISTS public.ACCOUNT
CREATE TABLE ACCOUNT (
    AccountNo INTEGER PRIMARY KEY,
	AccountType VARCHAR(100)
);

DROP TABLE IF EXISTS public.ACCOUNT
CREATE TABLE PRODUCT (
    ProductId INTEGER PRIMARY KEY,
	ProductName VARCHAR(100)
);

DROP TABLE IF EXISTS public.ACCOUNT
CREATE TABLE CUSTOMERACCOUNTPRODUCT (
    CustomerId INTEGER REFERENCES Customer(CustomerId),
	AccountNo INTEGER REFERENCES ACCOUNT(AccountNo),
	ProductId INTEGER REFERENCES PRODUCT(ProductId)
);

INSERT INTO CUSTOMER (CustomerId, Name, DOB) VALUES
(100, 'Hari', '12-05-1980'),
(101, 'Anirudh', '12-05-2011');

INSERT INTO ACCOUNT (AccountNo, AccountType) VALUES
(123456, 'Insurance Acct'),
(890823, 'Net Bank');

INSERT INTO PRODUCT (ProductId, ProductName) VALUES
(1, 'Content Cover'),
(2, 'Roof Cover'),
(3, 'Child Spend Protection'),
(4, 'Withdraw Limit');

INSERT INTO CUSTOMERACCOUNTPRODUCT (CustomerId, AccountNo, ProductId) VALUES
(100, 123456, 1),
(100, 123456, 2),
(101, 890823, 3),
(101, 890823, 4);

//query to have a table with all these attributes
SELECT
  c.CustomerId,
  c.Name, 
  c.DOB,
  a.AccountNo,
  a.AccountType,
  p.ProductId,
  p.ProductName
FROM CUSTOMERACCOUNTPRODUCT cap
JOIN Customer c ON cap.CustomerId = c.CustomerId
JOIN Account a ON cap.AccountNo = a.AccountNo
JOIN Product p ON cap.ProductId = p.ProductId;

//function here//
CREATE OR REPLACE FUNCTION get_customer_details(customer_id INTEGER)
RETURNS TABLE (
    CustomerId INTEGER,
    Name VARCHAR,
    DOB DATE,
    AccountNo INTEGER,
    AccountType VARCHAR,
    ProductId INTEGER,
    ProductName VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.CustomerId,
        c.Name,
        c.DOB,
        a.AccountNo,
        a.AccountType,
        p.ProductId,
        p.ProductName
    FROM CUSTOMERACCOUNTPRODUCT cap
    JOIN CUSTOMER c ON cap.CustomerId = c.CustomerId
    JOIN ACCOUNT a ON cap.AccountNo = a.AccountNo
    JOIN PRODUCT p ON cap.ProductId = p.ProductId
    WHERE c.CustomerId = customer_id;
END;
$$ LANGUAGE plpgsql;

//function here as JSON//
CREATE OR REPLACE FUNCTION get_customer_details_json(customer_id INTEGER)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(row_to_json(t))
    INTO result
    FROM (
        SELECT 
            c.CustomerId,
            c.Name,
            c.DOB,
            a.AccountNo,
            a.AccountType,
            p.ProductId,
            p.ProductName
        FROM CUSTOMERACCOUNTPRODUCT cap
        JOIN CUSTOMER c ON cap.CustomerId = c.CustomerId
        JOIN ACCOUNT a ON cap.AccountNo = a.AccountNo
        JOIN PRODUCT p ON cap.ProductId = p.ProductId
        WHERE c.CustomerId = customer_id
    ) t;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT get_customer_details_json(100);
