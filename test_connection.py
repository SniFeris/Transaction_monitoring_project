
import pyodbc

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=TransactionMonitoringProject;"
    "Trusted_Connection=yes;"
)

cursor = conn.cursor()

cursor.execute("SELECT name FROM sys.tables")

tables = cursor.fetchall()

for t in tables:
    print(t)

conn.close()

