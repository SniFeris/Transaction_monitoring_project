# AML Transaction Monitoring Simulator

A practical AML transaction monitoring simulation project built with **SQL Server** and **Python**, using synthetic client and transaction data.

This project simulates how an AML transaction monitoring environment can work in practice through:

- synthetic data generation
- rule-based alert generation
- client risk scoring
- suspicious activity pattern detection
- total risk score calculation

The project was built as a hands-on learning and portfolio project to better understand how transaction monitoring logic is structured in a realistic but controlled environment.

---

## Project Goals

The main goal of this project is to simulate the core logic behind a basic transaction monitoring system and show how different AML scenarios can be translated into SQL-based rules and scoring models.

This project focuses on:

- understanding transaction monitoring logic
- detecting suspicious transaction patterns
- separating **risk scoring** from **alert generation**
- building a realistic learning simulator using synthetic data

---

## Main Features

- Synthetic client generation
- Synthetic transaction generation
- Rule-based AML alert generation
- Total risk scoring view
- Configurable risk rules
- Clear separation between scoring logic and alert logic
- Detection of common suspicious transaction patterns

---

## Implemented Detection Logic

### 1. High-Risk Country Transfer
Generates an alert when a transaction is sent to a destination country marked as high risk in the rules table.

### 2. Large Single Transaction
Generates an alert when a single transaction exceeds the configured threshold.

### 3. Smurfing
Detects multiple small transactions that together form a significant total amount within a short period.

### 4. High-Frequency High-Volume Activity
Detects clients with frequent transactions and high total volume over the last 7 days.

### 5. Pass-Through Risk
Detects cases where incoming funds are quickly moved out in a similar amount, which may indicate layering or rapid movement of funds.

### 6. High Total Risk
Generates an alert when a client's total combined risk score exceeds the configured threshold.

---

## Risk Scoring Logic

The project uses a dedicated SQL view:

`dbo.vw_TotalRiskScoring`

This view combines multiple scoring components into a single total risk score.

### Scoring components
- Country risk
- High-frequency high-volume risk
- Single transaction amount risk
- Transaction type risk
- Smurfing risk
- Pass-through risk

The view also returns the latest transaction ID for each client so that a total risk alert can be linked to a transaction in the alerts table.

---

## Project Structure

### SQL files
- `01_create_database.sql` — creates the project database
- `02_create_tables.sql` — creates all required tables
- `03_insert_data.sql` — inserts reference and rules data
- `04_Alert_generation.sql` — generates alerts based on suspicious patterns
- `create_view_total_risk_scoring.sql` — creates the total risk scoring view

### Python files
- `generate_clients.py` — generates synthetic client data
- `generate_transactions.py` — generates synthetic transaction data
- `test_connection.py` — tests the SQL Server connection

### Configuration / other files
- `scenario.json` — scenario configuration
- `README.md` — project documentation

---

## Database Objects

The project currently uses the following main database objects.

### Core Tables

#### `dbo.Clients_table`
Stores synthetic client information.

Typical content:
- client identity fields
- country
- profile-related data

#### `dbo.Transactions_table`
Stores all synthetic transaction records generated for the simulation.

Typical content:
- transaction ID
- client ID
- amount
- transaction date
- direction
- transaction type
- destination country

#### `dbo.Alerts_table`
Stores generated AML alerts created by rule-based detection logic.

Typical content:
- alert ID
- transaction ID
- rule code
- alert status
- created timestamp

#### `dbo.ClientRiskAssessment_table`
Stores client risk assessment history.

Typical content:
- assessment ID
- client ID
- risk score
- risk level ID
- reason
- assessment timestamp

#### `dbo.RiskRules_table`
Stores configurable AML risk rules used by scoring and alert logic.

Typical content:
- rule type
- rule value
- points
- risk level / status fields depending on implementation

#### `dbo.RiskLevels_table`
Stores predefined risk levels and score ranges.

Used to classify or structure risk scoring results.

#### `dbo.TransactionType_table`
Stores reference data for transaction types.

Examples:
- Crypto Transfer
- International Transfer
- Cash Deposit
- Domestic Transfer
- Card Payment

#### `dbo.ImportCountries_stage`
Staging table used for country import / supporting country loading logic.

---

## View

### `dbo.vw_TotalRiskScoring`
A SQL view that calculates total client risk score by combining multiple scoring components.

Returned fields include:
- client identity fields
- component risk scores
- total risk score
- latest transaction ID

---

## Alert Rules Included

The alert generation script currently supports alerts such as:

- `HighRiskCountryTransfer`
- `LargeSingleTransaction`
- `Smurfing`
- `HighFrequencyHighVolume`
- `PassThroughRisk`
- `HighTotalRisk`

---

## How to Run the Project

Run the project in the following order.

### 1. Create the database
Run:

01_create_database.sql

### 2. Create all tables
Run:

02_create_tables.sql

### 3. Insert reference and rules data
Run:

03_insert_data.sql

### 4. Generate syntetic clients
Run:

python generate_clients.py

### 5. Generate syntetic transactions

Run:

python generate_transactions.py

## Database Objects

The project currently uses the following main database objects.

### Core Tables

#### `dbo.Clients_table`
Stores synthetic client information.

Typical content:
- client identity fields
- country
- profile-related data

#### `dbo.Transactions_table`
Stores all synthetic transaction records generated for the simulation.

Typical content:
- transaction ID
- client ID
- amount
- transaction date
- direction
- transaction type
- destination country

#### `dbo.Alerts_table`
Stores generated AML alerts created by rule-based detection logic.

Typical content:
- alert ID
- transaction ID
- rule code
- alert status
- created timestamp

#### `dbo.ClientRiskAssessment_table`
Stores client risk assessment history.

Typical content:
- assessment ID
- client ID
- risk score
- risk level ID
- reason
- assessment timestamp

#### `dbo.RiskRules_table`
Stores configurable AML risk rules used by scoring and alert logic.

Typical content:
- rule type
- rule value
- points
- risk level / status fields depending on implementation

#### `dbo.RiskLevels_table`
Stores predefined risk levels and score ranges.

Used to classify or structure risk scoring results.

#### `dbo.TransactionType_table`
Stores reference data for transaction types.

Examples:
- Crypto Transfer
- International Transfer
- Cash Deposit
- Domestic Transfer
- Card Payment

#### `dbo.ImportCountries_stage`
Staging table used for country import / supporting country loading logic.

---

## View

### `dbo.vw_TotalRiskScoring`
A SQL view that calculates total client risk score by combining multiple scoring components.

Returned fields include:
- client identity fields
- component risk scores
- total risk score
- latest transaction ID
