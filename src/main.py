import psycopg2
import csv
import re
from datetime import datetime

# -----------------------------
# DATABASE CONNECTION
# -----------------------------
conn = psycopg2.connect(
    dbname="Reporting_Platform",
    user="postgres",
    password="root",
    host="localhost",
    port="5432"
)
cursor = conn.cursor()

# -----------------------------
# FILE PATHS
# -----------------------------
sponsor_csv = r"E:\Arjun\Software\Data Reporting Platform\NPO_Web_App\src files\sponsor_20250216.csv"
transfer_csv = r"E:\Arjun\Software\Data Reporting Platform\NPO_Web_App\src files\Sponsor_Transfer_20250216.csv"
address_csv = r"E:\Arjun\Software\Data Reporting Platform\NPO_Web_App\src files\sponsoraddress_20250216.csv"

# -----------------------------
# Extract business date from filename
# -----------------------------
def extract_businessdate(path):
    match = re.search(r'(\d{8})(?=\.csv$)', path, re.IGNORECASE)
    return match.group(1) if match else None

# -----------------------------
# GENERIC LOADER FUNCTION
# -----------------------------
def load_csv_to_table(csv_path, schema, table, date_columns=None, delimiter=","):
    print(f"Loading {table}...")

    businessdate = extract_businessdate(csv_path)

    # Get DB columns
    cursor.execute(f"""
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = '{schema}'
          AND table_name = '{table}';
    """)
    db_columns = {row[0] for row in cursor.fetchall()}

    with open(csv_path, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter=delimiter)

        for row in reader:
            # Keep only matching columns
            filtered_row = {col: row[col] for col in row if col in db_columns}

            # Add businessdate if column exists
            if "businessdate" in db_columns:
                filtered_row["businessdate"] = businessdate

            # Convert date columns
            if date_columns:
                for dcol in date_columns:
                    if dcol in filtered_row and filtered_row[dcol]:
                        try:
                            filtered_row[dcol] = datetime.strptime(filtered_row[dcol], "%d/%m/%Y").date()
                        except:
                            filtered_row[dcol] = None

            # Build SQL
            columns = ", ".join(filtered_row.keys())
            placeholders = ", ".join(["%s"] * len(filtered_row))
            values = list(filtered_row.values())

            sql = f"""
                INSERT INTO {schema}.{table} ({columns})
                VALUES ({placeholders});
            """

            cursor.execute(sql, values)

    print(f"{table} loaded successfully.\n")

# -----------------------------
# LOAD EACH STAGING TABLE
# -----------------------------

# 1. stg_sponsor
load_csv_to_table(
    csv_path=sponsor_csv,
    schema="data_rpt_plaform",
    table="stg_sponsor",
    date_columns=["sponsor_dob", "sponsor_start_dt"]
)

# 2. stg_sponsor_transfer (TAB DELIMITED)
load_csv_to_table(
    csv_path=transfer_csv,
    schema="data_rpt_plaform",
    table="stg_sponsor_transfer",
    delimiter="\t"
)

# 3. stg_sponsor_address
load_csv_to_table(
    csv_path=address_csv,
    schema="data_rpt_plaform",
    table="stg_sponsor_address"
)

# -----------------------------
# FINALIZE
# -----------------------------
conn.commit()
cursor.close()
conn.close()

print("All staging tables loaded successfully!")