 
--======================================
--SECTION: ALERTS GENERATION
--This section generates alerts based on detected suspicious transaction patterns
--======================================

--High risk country transfer alert generation
WITH HighRiskCountryTransfers AS (
    SELECT
        t.TransactionID,
        t.ClientID,
        t.DestinationCountry
    FROM dbo.Transactions_table t
    JOIN dbo.RiskRules_table r
       ON t.DestinationCountry = r.RuleValue
    WHERE r.Ruletype = 'Country'
      AND r.IsActive = 1
      AND r.RiskLevel = 'High'
)
--Insert high risk country alert
INSERT INTO dbo.Alerts_table
(TransactionID, RuleCode, AlertStatus)
SELECT
     h.TransactionID,
     'HighRiskCountryTransfer',
     'Open'
FROM HighRiskCountryTransfers h
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Alerts_table a
    WHERE a.TransactionID =
h.TransactionID
      AND a.RuleCode = 'HighRiskCountryTransfer'
);

--Large single transaction alert generation
WITH LargeSingleTransactionCandidates AS (
    SELECT
         t.TransactionID,
         t.ClientID,
         t.Amount
    FROM dbo.Transactions_table t
    WHERE t.Amount >= 10000
)
--Insert large single transaction alert
INSERT INTO dbo.Alerts_table
(TransactionID, RuleCode, AlertStatus)
SELECT
     l.TransactionID,
     'LargeSingleTransaction',
     'Open'
FROM LargeSingleTransactionCandidates l
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Alerts_table a
    WHERE a.TransactionID =
    l.TransactionID
        AND a.RuleCode = 
    'LargeSingleTransaction'
);

--Smurfing detection and alert generation
WITH SmurfingCandidates AS (
    SELECT
        ClientID,
        CAST(TransactionDate AS DATE)
AS TxnDate,
        COUNT(*) AS TxnCount,
        SUM(Amount) AS TotalAmount,
        MAX(TransactionID) AS
LastTransactionID
    FROM dbo.Transactions_table t
    WHERE t.Amount < 1000
    GROUP BY t.ClientID,
CAST(TransactionDate AS DATE)
    HAVING COUNT(*) >= 5
             AND SUM(Amount) > 5000
)
--Insert alerts for detected smurfing patterns, avoiding duplicates
INSERT INTO dbo.Alerts_table
(TransactionID, RuleCode, AlertStatus)
SELECT
     LastTransactionID,
     'Smurfing',
     'Open'
FROM SmurfingCandidates sc
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Alerts_table a
    WHERE a.TransactionID = sc.LastTransactionID
        AND a.Rulecode = 'Smurfing'
);

--High-frequency high-volume alert generation
WITH HighFrequencyHighVolumeCandidates AS (
    SELECT
        t.ClientID,
        MAX(t.TransactionID) AS
LastTransactionID,
        COUNT(t.TransactionID) AS
TxCountLast7Days,
        SUM(t.Amount) AS
TotalAmountLast7Days
    FROM dbo.Transactions_table t
    WHERE t.TransactionDate >= DATEADD(day, -7, GETDATE())
    GROUP BY t.ClientID
    HAVING COUNT(t.TransactionID) >= 5
        AND SUM(t.Amount) >= 25000
)
--Insert high frequency high volume alert
INSERT INTO dbo.Alerts_table (TransactionID, RuleCode, AlertStatus)
SELECT
    h.LastTransactionID,
    'HighFrequencyHighVolume',
    'Open'
FROM HighFrequencyHighVolumeCandidates h
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Alerts_table a
    WHERE a.TransactionID = h.LastTransactionID
       AND a.RuleCode = 'HighFrequencyHighVolume'
);  

--Pass-through alert generation
WITH PassThroughCandidates AS (
    SELECT
        t_in.ClientID,
        MAX(t_out.TransactionID) AS LastTransactionID
    FROM dbo.Transactions_table t_in
    JOIN dbo.Transactions_table t_out
        ON t_in.ClientID = t_out.ClientID
       AND t_in.Direction = 'Incoming'
       AND t_out.Direction = 'Outgoing'
       AND t_out.TransactionDate > t_in.TransactionDate
       AND DATEDIFF(HOUR, t_in.TransactionDate, t_out.TransactionDate) BETWEEN 0 AND 24
       AND t_in.Amount >= 1000
       AND t_out.Amount >= t_in.Amount * 0.85
       AND t_out.Amount <= t_in.Amount * 1.05
    GROUP BY t_in.ClientID
)
--Insert pass through alert
INSERT INTO dbo.Alerts_table (TransactionID, RuleCode, AlertStatus)
SELECT
    p.LastTransactionID,
    'PassThroughRisk',
    'Open'
FROM PassThroughCandidates p
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Alerts_table a
    WHERE a.TransactionID = p.LastTransactionID
      AND a.RuleCode = 'PassThroughRisk'
);















