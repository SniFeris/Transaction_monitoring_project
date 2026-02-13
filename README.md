# Transaction Monitoring Project

SQL-based transaction monitoring database inspired by AML (Anti-Money Laundering) principles.

---

## 📌 Project Purpose

This project simulates a simplified transaction monitoring system used in financial institutions.

It demonstrates:

- Relational database design
- Primary Keys and Foreign Keys
- Data integrity using constraints
- Risk level classification
- Seed data initialization
- Transaction-to-client relationships

---

## 🗄️ Database Structure

### 1️⃣ RiskLevels_table
Stores predefined risk levels and score ranges.

| Column | Description |
|--------|------------|
| RiskLevelID | Primary key |
| RiskLevelName | Low / Medium / High |
| MinScore | Minimum risk score |
| MaxScore | Maximum risk score |

Includes UNIQUE constraint on RiskLevelName.

---

### 2️⃣ Clients_table
Stores client master data.

| Column | Description |
|--------|------------|
| ClientID | Primary key |
| Name | Client name |
| Country | Country of residence |
| Address | Client address |
| OnboardingDate | Date client was onboarded |
| DateOfBirth | Date of birth |
| RiskLevelID | Foreign key to RiskLevels_table |
| Status | Active / Inactive |

Each client must reference a valid risk level.

---

### 3️⃣ Transactions_table
Stores financial transactions for monitoring.

| Column | Description |
|--------|------------|
| TransactionID | Primary key |
| ClientID | Foreign key to Clients_table |
| Amount | Transaction amount |
| Currency | Transaction currency |
| Type | Deposit / Withdrawal |
| Status | Completed / Pending |
| RiskLevelID | Foreign key to RiskLevels_table |
| TransactionDate | Date and time of transaction |

Ensures every transaction references a valid client and risk level.

---

### 4️⃣ ClientRiskAssessment_table
Stores client risk assessment history.

| Column | Description |
|--------|------------|
| AssessmentID | Primary key |
| ClientID | Foreign key |
| RiskScore | Numeric score |
| RiskLevelID | Foreign key |
| Reason | Explanation of risk |
| AssessedAt | Timestamp (default GETDATE()) |

---

## ⚙️ Technical Concepts Used

- PRIMARY KEY
- FOREIGN KEY
- UNIQUE constraint
- IDENTITY (auto-increment)
- DEFAULT GETDATE()
- DROP TABLE IF EXISTS (safe re-run)
- Seed data insertion

---

## 🚀 How to Run

1. Execute:
   - `01_create_database.sql`
   - `02_create_tables.sql`
   - `03_insert_data.sql`

2. Run queries from:
   - `04_queries.sql`

---

## 👤 Author

Created by Ivo  
SQL & AML-focused project

