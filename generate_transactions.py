#AML transaction data generator script
#Import required libraries
import random
import pyodbc
import json
from datetime import datetime, timedelta
from faker import Faker
fake = Faker()

#Load countries from txt file
def load_country_list(file_path):
    with open(file_path, "r",
encoding="utf-8") as f:
        return [line.strip() for line
in f if line.strip()]

#Load AML country risk lists  
fatf_black = load_country_list("SQL/fatf_black_list.txt")
eu_high = load_country_list("SQL/eu_high_risk_countries.txt")
grey_list = load_country_list("SQL/fatf_grey_list.txt")


#Define risk groups
high_risk_countries = list(set(fatf_black + eu_high))
medium_risk_countries = grey_list
risk_countries = list(set(high_risk_countries + medium_risk_countries))

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
    destination_country = fake.country()
    transaction_date = datetime.now() - timedelta(days=random.randint(0, 30))
    if random.random() < 0.3:
       status = "Flagged"
    else:
        status = "Approved"
    
#Insert generated transactions into SQL server  
    cursor.execute("""
           INSERT INTO dbo.Transactions_table
           (ClientID, Amount, Currency, TransactionTypeId, Status, DestinationCountry, TransactionDate)
           VALUES (?, ?, ?, ?, ?, ?, ?)
           """, client_id, amount, "EUR", transaction_type_id, status, destination_country, transaction_date)

conn.commit()
cursor.close()
conn.close()