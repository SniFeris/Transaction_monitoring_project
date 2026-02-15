USE TransactionMonitoringProject
GO
SELECT DB_NAME() AS CurrentDB;

SELECT name
FROM sys.tables

INSERT INTO dbo.Clients_table
(Name, Country, Address, Onboardingdate, DateOfBirth, RiskLevelID, Status)
VALUES ('Test client', 'LV', 'Riga', CAST(GETDATE() AS date), '1990-01-01',1,'Active')

SELECT * FROM dbo.Clients_table

INSERT INTO dbo.Transactions_table
(ClientID, Amount, Currency, TransactionTypeID, RiskLevelID,
TransactionDate)
VALUES(12, 10,'EUR',1,1,GETDATE());

SELECT * FROM dbo.TransactionType_table

SELECT TOP 1 TransactionID, Status
FROM dbo.Transactions_table
ORDER BY TransactionID DESC


SELECT * FROM dbo.Clients_table
SELECT * FROM dbo.TransactionType_table
SELECT * FROM dbo.RiskLevels_table

SELECT * FROM dbo.Transactions_table
    