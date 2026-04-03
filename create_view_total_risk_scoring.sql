--====================================
--TRANSACTION MONITORING PROJECT
--Risk scoring and alert generation
--====================================
--SECTION: RISK SCORING
--This section calculates risk scores based on transaction behavior
--====================================
--Country risk: Assigns risk points based on clients country
GO
CREATE OR ALTER VIEW
dbo.vw_TotalRiskScoring AS
WITH CountryRisk AS (
SELECT
    c.ClientID,
    c.Name,
    c.Country,
    SUM(r.Points) AS CountryRiskScore

FROM dbo.Clients_table c
JOIN dbo.RiskRules_table r
    ON c.Country = r.RuleValue
WHERE r.RuleType = 'Country'
   AND r.IsActive = 1
GROUP BY 
    c.ClientID,
    c.Name,
    c.country
),

--High-frequency high-volume risk: frequent transactions with large total amounts in last 7 days
HighFrequencyHighVolumeRisk AS (
   SELECT
    t.ClientID,
    COUNT(t.TransactionID) AS
TxCountLast7Days,
    CASE
       WHEN COUNT(t.TransactionID) >= 8 AND SUM(Amount) >= 50000 THEN 30
       WHEN COUNT(t.TransactionID) >= 5 AND SUM(Amount) >= 25000  THEN 20       
        ELSE 0
     END AS HighFrequencyHighVolumeRiskScore
    FROM dbo.Transactions_table t
    WHERE t.TransactionDate >= DATEADD(day, -7, GETDATE())
    GROUP BY t.ClientID
),

--Single transaction amount risk: highest risk from a single transaction--
SingleTxAmountRisk AS (
    SELECT    
     t.ClientID,
     MAX(
    
       CASE
          WHEN t.Amount >= 10000 THEN 10
          WHEN t.Amount >= 5000 THEN 6
          WHEN t.Amount >= 2000 THEN 3
           ELSE 0
         END ) AS SingleTxAmountRiskScore
       FROM dbo.Transactions_table t
       GROUP BY t.ClientID
),

--Transaction type risk: highest risk based on transaction type used --by the client
TransactionTypeRisk AS (
   SELECT    
    t.clientID,
        MAX(   

        CASE
          WHEN tt.TransactionTypeName = 'Cripto Transfer' THEN 15
          WHEN tt.TransactionTypeName = 'Cash Withdraval' THEN 10
          WHEN tt.TransactionTypeName = 'ATM Withdraval' THEN 6
          WHEN tt.TransactionTypeName = 'International Transfer' THEN 12
          WHEN tt.TransactionTypeName = 'Domestic Transfer' THEN 4
          WHEN tt.TransactionTypeName = 'Card Payment' THEN 2
          WHEN tt.TransactionTypeName = 'Cash Deposit' THEN 8
           ELSE 0
           END ) AS TransactionTypeRiskScore
        FROM dbo.Transactions_table t
        JOIN dbo.TransactionType_table tt
          ON t.TransactionTypeID = tt.TransactionTypeID
        GROUP BY t.ClientID
),

--Smurfing risk: structured transactions below single-transfer threshold whithin 7 days
SmurfingRisk AS (
    SELECT
        t.ClientID,
        CASE
           WHEN COUNT(*) >= 5 AND SUM(t.Amount) >= 10000 AND MAX(t.Amount) < 10000 THEN 50
           ELSE 0

        END AS SmurfingRiskScore
        FROM dbo.Transactions_table t
        WHERE t.Amount < 1000
          AND t.TransactionDate >=
        DATEADD(day, -7, GETDATE())
        GROUP BY t.ClientID
         
),

--Pass-through risk scoring
PassThroughRisk AS (
    SELECT
         t_in.ClientID,
         MAX(CASE WHEN t_in.Amount >= 500 AND t_out.Amount >= t_in.Amount * 0.9
             AND t_out.Amount <= t_in.Amount * 1.05
             AND DATEDIFF(HOUR, t_in.TransactionDate, t_out.TransactionDate) BETWEEN 0 AND 1 THEN 25
             WHEN t_in.Amount >= 500 AND t_out.Amount >= t_in.Amount * 0.8
             AND t_out.Amount <= t_in.Amount * 0.8
             AND t_out.Amount <= t_in.Amount * 1.05
             AND DATEDIFF(HOUR, t_in.TransactionDate, t_out.TransactionDate) BETWEEN 0 AND 24 THEN 15
             ELSE 0
          END
             ) AS PassThroughRiskScore
             FROM dbo.Transactions_table t_in
             JOIN dbo.Transactions_table t_out
              ON t_in.ClientID = t_out.ClientID
              AND t_in.Direction = 'Incoming'
              AND t_out.Direction = 'Outgoing'
              AND t_out.TransactionDate > t_in.TransactionDate
            GROUP BY t_in.ClientID
                 ) 

--Final risk score calculation: combines all risk indicators into Total risk score--
SELECT
     cr.ClientID,
     cr.Name,
     cr.Country,
     MAX(t.TransactionID) AS LastTransactionID,
     cr.CountryRiskScore,
     ISNULL(hfhv.HighFrequencyHighVolumeRiskScore, 0) 
  AS FrequencyRiskScore,  
     ISNULL(st.SingleTxAmountRiskScore, 0)
  AS SingleTxAmountRiskScore,
     ISNULL(tt.TransactionTypeRiskScore, 0)
  AS TransactionTypeRiskScore,
     ISNULL(sr.SmurfingRiskScore, 0)
  AS SmurfingRiskScore,
     ISNULL(ptr.PassThroughRiskScore, 0)
  AS PassThroughRiskRiskScore,

    cr.CountryRiskScore
    + ISNULL(hfhv.HighFrequencyHighVolumeRiskScore, 0)   
    + ISNULL(st.SingleTxAmountRiskScore, 0)
    + ISNULL(tt.TransactionTypeRiskScore, 0)
    + ISNULL(sr.SmurfingRiskScore, 0)
    + ISNULL(ptr.PassThroughRiskScore, 0)

AS TotalRiskScore
  FROM CountryRisk cr
  LEFT JOIN Transactions_table t
      ON cr.ClientID = t.ClientID
  LEFT JOIN HighFrequencyHighVolumerisk hfhv
      ON cr.ClientID = hfhv.ClientID  
  LEFT JOIN SingleTxAmountRisk st
      ON cr.ClientID = st.ClientID
  LEFT JOIN TransactionTypeRisk tt
      ON cr.ClientID = tt.ClientID
  LEFT JOIN SmurfingRisk sr
      ON cr.ClientID = sr.ClientID
  LEFT JOIN PassThroughRisk ptr
      ON cr.ClientID = ptr.ClientID
    GROUP BY
        cr.ClientID,
        cr.Name,
        cr.Country,
        cr.CountryRiskScore,

    hfhv.HighFrequencyHighVolumeRiskScore,
    st.SingleTxAmountRiskScore,
    tt.TransactionTypeRiskScore,
    sr.SmurfingRiskScore,
    ptr.PassThroughRiskScore
GO