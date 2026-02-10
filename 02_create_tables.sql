--Creates core database tables for the system

--use main database--
USE TransactionMonitoringProject;
GO

--drop tables if they alredy exists for re-run safety)
DROP TABLE if EXISTS
Transactions_table;
DROP TABLE if EXISTS Clients_table;
GO

CREATE TABLE Clients_table (
    ClientID int IDENTITY(1,1) not null PRIMARY KEY, 
    Name NVARCHAR(50) not null,
    Country NVARCHAR(50) not null,
    Address NVARCHAR(150) not null,
    Onboardingdate date not null,
    DateOfBirth date not null,
    RiskLevel NVARCHAR(20) not null,
    Status NVARCHAR(20) not null

);

GO

CREATE TABLE Transactions_table (
    TransactionID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClientID int NOT NULL,
    Amount DECIMAL(18,2),
    Currency NVARCHAR(5) NOT NULL,
    Type NVARCHAR(20),
    Status NVARCHAR(20),
    RiskLevel NVARCHAR(20),
    TransactionDate datetime NOT NULL,

    CONSTRAINT FK_Transactions_clients
         FOREIGN KEY (ClientID)
         REFERENCES
    dbo.Clients_table(ClientID)
);

    GO

--Check table structure==

EXEC sp_help 'dbo.clients_table';
EXEC sp_help 'dbo.Transactions_table';
