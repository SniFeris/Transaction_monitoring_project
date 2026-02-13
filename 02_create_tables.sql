--Creates core database tables for the system

--use main database--
USE TransactionMonitoringProject;
GO

--drop tables if they already exist (safe re-run)
DROP TABLE if EXISTS
dbo.ClientRiskAssessment_table;
DROP TABLE if EXISTS
dbo.Transactions_table; 
DROP TABLE if EXISTS
dbo.Clients_table;
DROP TABLE if EXISTS
dbo.TransactionType_table;
DROP TABLE if EXISTS
dbo.RiskLevels_table;
GO

--Stores predefined risk levels and score ranges--
CREATE TABLE dbo.RiskLevels_table (
    RiskLevelID INT IDENTITY(1,1) NOT
NULL PRIMARY KEY,
    RiskLevelName NVARCHAR(20) NOT NULL,
    MinScore INT NOT NULL,
    MaxScore INT NOT NULL,
    CONSTRAINT UQ_RiskLevels_RiskLevelName UNIQUE 
    (RiskLevelName)
    );
    GO
--Stores predefined transaction types--
CREATE TABLE dbo.TransactionType_table (
    TransactionTypeID INT IDENTITY(1, 1)
NOT NULL PRIMARY KEY,
    TransactionTypeName NVARCHAR(50)
NOT NULL,

    CONSTRAINT UQ_TransactionType_Name
UNIQUE (TransactionTypeName)
);
GO

--Stores customer master data--
CREATE TABLE dbo.Clients_table (
    ClientID int IDENTITY(1,1) not null PRIMARY KEY, 
    Name NVARCHAR(50) not null,
    Country NVARCHAR(50) not null,
    Address NVARCHAR(150) not null,
    Onboardingdate date not null,
    DateOfBirth date not null,
    RiskLevelID INT not null,
    Status NVARCHAR(20) not null

     CONSTRAINT FK_Clients_RiskLevel
          FOREIGN KEY (RiskLevelID)
          REFERENCES
    dbo.RiskLevels_table(RiskLevelID)

);
GO

--Stores client transactions for monitoring--
CREATE TABLE dbo.Transactions_table (
    TransactionID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ClientID INT NOT NULL,
    Amount DECIMAL(18,2),
    Currency NVARCHAR(5) NOT NULL,
    TransactionTypeID INT NOT NULL,
    Status NVARCHAR(20),
    RiskLevelID INT NOT NULL,
    TransactionDate datetime NOT NULL,
--Ensures each transaction references a valid client and risk level--
    CONSTRAINT FK_Transactions_clients
         FOREIGN KEY (ClientID)
         REFERENCES
    dbo.Clients_table(ClientID),
    CONSTRAINT FK_Transactions_Risklevel
         FOREIGN KEY (RiskLevelID)
         REFERENCES
    dbo.RiskLevels_table(RiskLevelID),
    CONSTRAINT FK_Transactions_TransactionType
         FOREIGN KEY (TransactionTypeID)
         REFERENCES
    dbo.TransactionType_table(TransactionTypeID)
);
GO

--Stores client risk assessment history--
  CREATE TABLE dbo.ClientRiskAssessment_table (
     AssessmentID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
     ClientID INT NOT NULL,
     RiskScore INT NOT NULL,
     RisklevelID INT NOT NULL,
     Reason NVARCHAR(255) NULL,
     AssessedAt DATETIME NOT NULL
DEFAULT GETDATE(),
--Links assesment to existing client and risk level--
  CONSTRAINT FK_Assessment_Client
      FOREIGN KEY (ClientID)
  REFERENCES dbo.Clients_table(ClientID),

       CONSTRAINT FK_assessment_RiskLevel
         FOREIGN KEY (RiskLevelID)
   REFERENCES 
   dbo.RiskLevels_table(RiskLevelID)
);
GO


