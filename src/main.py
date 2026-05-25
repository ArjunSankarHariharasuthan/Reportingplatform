# main.py

import psycopg2
from staging_load import load_csv_to_table
from transform_load import run_transformations

# -----------------------------
# DATABASE CONNECTION
# -----------------------------
def get_connection():
    return psycopg2.connect(
        dbname="Reporting_Platform",
        user="postgres",
        password="root",
        host="localhost",
        port="5432"
    )

# -----------------------------
# MAIN PIPELINE
# -----------------------------
def main():
    conn = get_connection()

    # FILE PATHS
    sponsor_csv = r"E:\Arjun\Software\Data Reporting Platform\NPO_Web_App\src files\sponsor_20250216.csv"
    transfer_csv = r"E:\Arjun\Software\Data Reporting Platform\NPO_Web_App\src files\Sponsor_Transfer_20250216.csv"
    address_csv = r"E:\Arjun\Software\Data Reporting Platform\NPO_Web_App\src files\sponsoraddress_20250216.csv"

    # 1. Load staging tables
    load_csv_to_table(
        conn=conn,
        csv_path=sponsor_csv,
        schema="data_rpt_plaform",
        table="stg_sponsor",
        date_columns=["sponsor_dob", "sponsor_start_dt"]
    )

    load_csv_to_table(
        conn=conn,
        csv_path=transfer_csv,
        schema="data_rpt_plaform",
        table="stg_sponsor_transfer",
        delimiter="\t"
    )

    load_csv_to_table(
        conn=conn,
        csv_path=address_csv,
        schema="data_rpt_plaform",
        table="stg_sponsor_address"
    )

    # 2. Run transformations
    run_transformations(conn)

    conn.close()
    print("Pipeline completed successfully.")

if __name__ == "__main__":
    main()