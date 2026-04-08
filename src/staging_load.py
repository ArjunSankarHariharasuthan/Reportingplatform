import psycopg2
import csv
from datetime import datetime

# Database connection config
conn = psycopg2.connect(
    dbname="Reporting_Platform",
    user="postgres",
    password="root",
    host="localhost",
    port="5432"
)

cursor = conn.cursor()

# Paths to your CSV files
customer_csv_path = r'E:\Arjun\Software\SAP\Outbound\customer_20250801010830.csv'
address_type_csv_path = r"E:\Arjun\Software\SAP\Outbound\address_type.csv"
account_type_csv_path = r"E:\Arjun\Software\SAP\Outbound\account_type.csv"
account_csv_path = r"E:\Arjun\Software\SAP\Outbound\account.csv"  # Account data CSV
address_csv_path = r"E:\Arjun\Software\SAP\Outbound\address.csv"  # Address data CSV
customeraddress_csv_path = r"E:\Arjun\Software\SAP\Outbound\customer_address.csv"  # Customer Address data CSV

# --- Importing customer data ---
with open(customer_csv_path, mode='r', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for row in reader:
        try:
            # Parse dob from MM/DD/YYYY to date object
            dob = datetime.strptime(row['dob'], '%m/%d/%Y').date()
        except ValueError:
            dob = None  # Handle invalid date formats

        cursor.execute("""
            INSERT INTO "Raw_Layer".stg_rsap_customer 
            (customer_id, customer_name, source_customer_num, customer_dob, customer_start_date)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT (customer_id) DO NOTHING;
        """, (
            int(row['customerid']),
            row['name'],
            row['cifid'],
            dob,
            None  # customer_start_date is NULL
        ))

# --- Importing Address Type data ---
with open(address_type_csv_path, mode='r', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for row in reader:
        cursor.execute("""
            INSERT INTO "Raw_Layer".stg_rsap_address_type 
            (address_type_cd, address_type_name, address_type_desc)
            VALUES (%s, %s, %s)
            ON CONFLICT (address_type_cd) DO NOTHING;
        """, (
            int(row['address_type_cd']),
            row['address_type_name'],
            row['address_type_desc']
        ))

# --- Importing Account Type data ---
with open(account_type_csv_path, mode='r', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for row in reader:
        cursor.execute("""
            INSERT INTO "Raw_Layer".stg_rsap_account_type 
            (account_type_cd, account_type_name, account_type_desc)
            VALUES (%s, %s, %s)
            ON CONFLICT (account_type_cd) DO NOTHING;
        """, (
            int(row['accounttypecd']),
            row['accounttypename'],
            row['accounttypedesc']
        ))

# --- Importing Account data ---
with open(account_csv_path, mode='r', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for row in reader:
        cursor.execute("""
            INSERT INTO "Raw_Layer".stg_rsap_account 
            (source_account_no, card_number, account_type_cd)
            VALUES (%s, %s, %s)
            ON CONFLICT (source_account_no) DO NOTHING;
        """, (
            row['sourceaccountno'],  # Correct column name here
            row['cardnumber'],       # Correct column name here
            1  # account_type_cd is set to 1 for all records
        ))

# --- Importing Address data ---
with open(address_csv_path, mode='r', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for row in reader:
        cursor.execute("""
            INSERT INTO "Raw_Layer".stg_rsap_address 
            (address_id, unit_no, street_no, street_name, suburb_name, postal_cd, state_code, state_name)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (address_id) DO NOTHING;
        """, (
            int(row['address_id']),
            row['unit_no'] if row['unit_no'] else None,  # Handle possible null unit_no
            row['street_no'],
            row['street_name'],
            row['suburb_name'],
            row['postal_cd'],
            row['state_code'],
            row['state_name']
        ))

# --- Importing Customer Address data ---
with open(customeraddress_csv_path, mode='r', encoding='utf-8') as f:
    reader = csv.DictReader(f)

    for row in reader:
        cursor.execute("""
            INSERT INTO "Raw_Layer".stg_rsap_customer_address 
            (customer_id, address_type_cd, customer_address_eff_date, customer_address_end_date)
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (customer_id, address_type_cd) DO NOTHING;
        """, (
            int(row['customerid']),
            int(row['addresstypecd']),
            datetime.strptime(row['customeraddresseffdate'], '%Y-%m-%d').date(),  # Adjusted date format
            datetime.strptime(row['customeraddressenddt'], '%Y-%m-%d').date()  # Adjusted date format
        ))

# Commit the changes to the database
conn.commit()

# Close the cursor and connection
cursor.close()
conn.close()

print("CSV data imported successfully into all tables!")
