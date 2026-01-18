from database import MSSQLConnection
import re

DB_HOST = "localhost"
DB_PORT = 1433
DB_NAME = "master"
DB_USER = "sa"
DB_PASSWORD = "ParolaComplexa123!"


def execute_sql_file(conn, filename):
    print(f"Executing {filename}...")
    try:
        with open(filename, "r", encoding="utf-8") as f:
            content = f.read()

        batches = re.split(r"^\s*GO\s*$", content, flags=re.MULTILINE | re.IGNORECASE)

        for batch in batches:
            if batch.strip():
                try:
                    conn.execute_query(batch)
                except Exception as e:
                    print(f"Error executing batch in {filename}:")
                    print(e)
        print(f"Finished executing {filename}.")
    except FileNotFoundError:
        print(f"Error: File {filename} not found.")


def main():
    print("Starting Full Database Reset...")
    try:
        conn = MSSQLConnection(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
        conn.openConnection()

        # Schema (Drops and Recreates Tables)
        execute_sql_file(conn, "schema.sql")

        # Procedures (Drops and Recreates Stored Procs)
        execute_sql_file(conn, "procedures.sql")

        # Seed Data
        execute_sql_file(conn, "seed_comprehensive.sql")

        # Cleanup artifacts
        try:
            conn.execute_query(
                "IF OBJECT_ID('TestTable', 'U') IS NOT NULL DROP TABLE TestTable"
            )
            print("Cleaned up 'TestTable'.")
        except:
            pass

        conn.closeConnection()
        print("Database Reset Complete! Tables recreated (Empty).")
    except Exception as e:
        print(f"Database Reset Failed: {e}")


if __name__ == "__main__":
    main()
