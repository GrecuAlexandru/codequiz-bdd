from database import MSSQLConnection
import sys

# Configuration
import os
from dotenv import load_dotenv

load_dotenv()

DB_HOST = 'localhost'
DB_PORT = 1433
DB_NAME = 'master' 
DB_USER = os.getenv('DB_USER', 'SA')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')

def print_table(name, columns, rows):
    if not rows:
        print(f"\n--- Table: {name} (Empty) ---")
        return

    print(f"\n--- Table: {name} ---")
    
    # Calculate column widths
    widths = [len(c) for c in columns]
    for row in rows:
        for i, val in enumerate(row):
            widths[i] = max(widths[i], len(str(val)))
            
    # Create format string
    fmt = " | ".join([f"{{:<{w}}}" for w in widths])
    
    # Print header
    print("-" * (sum(widths) + 3 * (len(columns) - 1)))
    print(fmt.format(*columns))
    print("-" * (sum(widths) + 3 * (len(columns) - 1)))
    
    # Print rows
    for row in rows:
        formatted_row = [str(val) if val is not None else 'NULL' for val in row]
        print(fmt.format(*formatted_row))
    print("-" * (sum(widths) + 3 * (len(columns) - 1)))

def main():
    try:
        conn = MSSQLConnection(DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD)
        conn.openConnection()
        
        # Get list of tables
        cursor = conn.execute_query("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME != 'sysdiagrams' ORDER BY TABLE_NAME")
        tables = [row[0] for row in cursor.fetchall()]
        
        for table in tables:
            try:
                # Get data
                cursor = conn.execute_query(f"SELECT * FROM {table}")
                rows = cursor.fetchall()
                
                # Get column names
                if cursor.description:
                    columns = [d[0] for d in cursor.description]
                    print_table(table, columns, rows)
                else:
                    print(f"\n--- Table: {table} (No Columns Found) ---")

            except Exception as e:
                print(f"Error reading table {table}: {e}")
                
        conn.closeConnection()
        
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    main()
