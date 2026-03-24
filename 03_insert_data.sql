USE TransactionMonitoringProject;
GO
--Seed default risk levels with score ranges--
IF not exists (select 1 FROM
dbo.RiskLevels_table)
    INSERT INTO dbo.RiskLevels_table
(RiskLevelName, MinScore, MaxScore)
VALUES
('Low', 0, 39),
('Medium',40, 69),
('High',70, 999);
GO

--Seed predefined transaction types--
DELETE from dbo.TransactionType_table
INSERT INTO dbo.TransactionType_table
(TransactionTypeName)
VALUES
('Cash Deposit'),
('Cash Withdrawal'),
('ATM Withdrawal'),
('International Transfer'),
('Domestic Transfer'),
('Card Payment'),
('Crypto Transfer')
 
GO







