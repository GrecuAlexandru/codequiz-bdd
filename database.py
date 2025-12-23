import pyodbc

class MSSQLConnection:
    def __init__(self, host, port, database, username, password):
        self.host = host
        self.port = port
        self.database = database
        self.username = username
        self.password = password
        self.db = None
        self.cursor = None

    def openConnection(self):
        try:
            driver_name = 'SQL Server'

            conn_str = (
                f"DRIVER={{{driver_name}}};"
                f"SERVER={self.host},{self.port};"
                f"DATABASE={self.database};"
                f"UID={self.username};"
                f"PWD={self.password};"
                "TrustServerCertificate=yes;"
            )
            
            self.db = pyodbc.connect(conn_str, autocommit=True)
            self.cursor = self.db.cursor()
            print("Connection open")
        except Exception as e:
            print("Connection not open")
            print(e)
            raise e

    def closeConnection(self):
        try:
            if self.cursor:
                self.cursor.close()
            if self.db:
                self.db.close()
            print("Connection closed")
        except Exception as e:
            print("Connection not closed")
            print(e)

    def execute_query(self, query, params=None):
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)
            return self.cursor
        except Exception as e:
            print(f"Error executing query: {e}")
            raise e
