#AML client data generator script
#Import required libraries
import json
import random
import pyodbc
from faker import Faker
#Initialize faker generator
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

#SQL server connection
conn = pyodbc.connect(
     "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=TransactionMonitoringProject;"
    "Trusted_Connection=yes;"
)
#Ceate cursor to execute SQL queries
cursor = conn.cursor()

#Load scenario configuration from JSON file
with open("scenario.json", "r",
encoding ="utf-8") as f:
    scenario = json.load(f)
#Extract clients configuration from scenario file
clients_config = scenario["Clients"]

total_clients = clients_config["total"]
low_risk_count = clients_config["Low_risk"]
medium_risk_count = clients_config["Medium_risk"]
high_risk_count = clients_config["High_risk"]

#Validate risk distribution
if low_risk_count + medium_risk_count + high_risk_count != total_clients:
    raise ValueError("Risk distribution does not match total clients")

#Create list of risk levels for clients
risk_levels = (
    [1] * low_risk_count +
    [2] * medium_risk_count +
    [3] * high_risk_count
)
#Shuffle risk clients order so clients are randomized
random.shuffle(risk_levels)

#Simulate account status distribution, more active accounts
statuses = ["Active", "Active", "Active", "Blocked"]

#Container for generated clients
clients = []

#Clear all generated cients before insert
cursor.execute("DELETE FROM dbo.Clients_table")

high_risk_countries = list(set(fatf_black + eu_high))
medium_risk_countries = grey_list

all_countries = [fake.country() for _ in range(500)]
low_risk_countries = list(set(all_countries) - set(high_risk_countries) - set(medium_risk_countries))
#Generte client records based on scenario configuration
for i in range(total_clients):
#Assign country based on risk level
    risk = risk_levels[i] 
    if risk == 3: country = random.choice(high_risk_countries)        
    elif risk == 2: country = random.choice(medium_risk_countries)        
    else: country = random.choice(low_risk_countries)         

#Create synthetic client record, data simulates realistic KYC onboarding information
    client = {
          "Name": fake.name(),
         "Country": country,
          "Address": f"{fake.street_address()}, {fake.city()}",
          "OnboardingDate": str(fake.date_between(start_date="-5y", end_date="today")),
          "DateOfBirth": str(fake.date_of_birth(minimum_age=18, maximum_age=75)),
          "KYCRiskLevelID": risk,
          "Status": random.choice(statuses)
    }
#Store generated client in memory list
    clients.append(client)

#Insert generated clients into SQL server
    cursor.execute("""
    INSERT INTO dbo.Clients_table
    (Name, Country, Address, Onboardingdate, DateOfBirth, KYCRiskLevelID, Status)
    VALUES (?, ?, ?, ?, ?, ?, ?)
""",
    client["Name"],
    client["Country"],
    client["Address"],    
    client["OnboardingDate"],
    client["DateOfBirth"],
    client["KYCRiskLevelID"],
    client["Status"]
    )
  
conn.commit()
cursor.close()
conn.close()

