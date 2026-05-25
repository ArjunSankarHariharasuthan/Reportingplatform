# staging_load.py

import csv
import re
from datetime import datetime
from notify_logger import send_failure   # <-- import your notifier

# -----------------------------
# Extract business date from filename
# -----------------------------
def extract_businessdate(path):
    match = re.search(r'(\d{8})(?=\.csv$)', path, re.IGNORECASE)
    return match.group(1) if match else None

# -----------------------------
# GENERIC LOADER FUNCTION
# -----------------------------
def load_csv_to_table(conn, csv_path, schema, table, date_columns=None, delimiter=","):
    cursor = conn.cursor()
    businessdate = extract_businessdate(csv_path)

    try:
        print(f"Loading {table}...")

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
                filtered_row = {col: row[col] for col in row if col in db_columns}

                if "businessdate" in db_columns:
                    filtered_row["businessdate"] = businessdate

                if date_columns:
                    for dcol in date_columns:
                        if dcol in filtered_row and filtered_row[dcol]:
                            try:
                                filtered_row[dcol] = datetime.strptime(filtered_row[dcol], "%d/%m/%Y").date()
                            except:
                                filtered_row[dcol] = None

                columns = ", ".join(filtered_row.keys())
                placeholders = ", ".join(["%s"] * len(filtered_row))
                values = list(filtered_row.values())

                sql = f"""
                    INSERT INTO {schema}.{table} ({columns})
                    VALUES ({placeholders});
                """

                cursor.execute(sql, values)

        conn.commit()
        print(f"{table} loaded successfully.\n")

    except Exception as e:
        conn.rollback()

        error_message = (
            f"STAGING LOAD FAILURE\n"
            f"Table: {table}\n"
            f"File: {csv_path}\n"
            f"Business Date: {businessdate}\n"
            f"Error: {str(e)}"
        )

        print(error_message)

        # 🔔 Notify support team
        send_failure(error_message)

    finally:
        cursor.close()