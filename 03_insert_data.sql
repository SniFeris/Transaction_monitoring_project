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
('High',70, 100);
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
--Make the script re-runable without duplicates--
DELETE FROM dbo.RiskRules_table WHERE
RuleType = 'Country'   
   AND Source = 'FATF'
--Clear staging table before loading new file--
TRUNCATE TABLE dbo.ImportCountries_stage;
--Load FATF blacklist countries from file--
BULK INSERT dbo.ImportCountries_stage
FROM 'C:\SQL\fatf_black_list.txt'
WITH (
    CODEPAGE = '65001',
    ROWTERMINATOR = '0x0a'
);
GO
--Insert FATF high risk countries in to main table--
INSERT INTO dbo.RiskRules_table
(RuleType, RuleValue, RiskLevel, Points, Source, IsActive)
SELECT DISTINCT
     'Country',
     TRIM(CountryName),
     'High',
     10,
     'FATF',
     1
FROM dbo.ImportCountries_stage
GO

DELETE FROM dbo.RiskRules_table WHERE
RuleType = 'Country'   
   AND Source = 'EU'

TRUNCATE TABLE dbo.ImportCountries_stage;
--Load EU high risk countries from file--
BULK INSERT dbo.ImportCountries_stage
FROM 'C:\SQL\eu_high_risk_countries.txt'
WITH (
    CODEPAGE = '65001',
    ROWTERMINATOR = '0X0a'
);
--Insert EU high risk countries in to main table--
INSERT INTO dbo.RiskRules_table
(RuleType, RuleValue, RiskLevel, Points, Source, IsActive)
SELECT DISTINCT
     'Country',
     TRIM(CountryName),
     'High', 
     10,
     'EU',
     1
FROM dbo.ImportCountries_stage;
GO


