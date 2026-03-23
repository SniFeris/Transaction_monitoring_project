#AML transaction data generator script
#Import required libraries
import random
import pyodbc
import json
from datetime import datetime, timedelta

#SQL server connection
conn = pyodbc.connect(
     "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=TransactionMonitoringProject;"
    "Trusted_Connection=yes;"
)
#Ceate cursor to execute SQL queries
cursor = conn.cursor()
cursor.execute("DELETE FROM dbo.Transactions_table")
conn.commit()

#Get all clients ID
cursor.execute("SELECT ClientID FROM dbo.Clients_table")
clients = [row[0] for row in cursor.fetchall()]

#Get all transaction type ID
cursor.execute("SELECT TransactionTypeID FROM dbo.TransactionType_table")
transaction_types = [row[0] for row in cursor.fetchall()]

#Load scenario configuration from JSON file
with open("scenario.json", "r",
encoding ="utf-8") as f:
    scenario = json.load(f)

#Extract transactions configuration from scenario file
transactions_config = scenario["transactions"]

per_client = transactions_config["per_client"]
max_amount = transactions_config["Max_amount"]

#Loop through each client from database
for client_id in clients:
#Random number of transactions for this client
   num_transactions = random.randint(1, per_client)
#Loop each transaction of client
   for i in range(num_transactions):
    transaction_type_id = random.choice(transaction_types)
    amount = round(random.uniform(10, max_amount), 2)
    
#Insert generated transactions into SQL server  
    cursor.execute("""
           INSERT INTO dbo.Transactions_table
           (ClientID, Amount, Currency, TransactionTypeId, Status, TransactionDate)
           VALUES (?, ?, ?, ?, ?, GETDATE())
           """, client_id, amount, "EUR", transaction_type_id, "Approved")

conn.commit()
cursor.close()
conn.close()