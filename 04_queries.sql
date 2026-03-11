/*Country risk Assigns risk points based on clients country*/
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
)
--Frequency risk: Calculates client frequency score based on transactions in last 7 days-
,FrequencyRisk AS (
   SELECT
    t.ClientID,
    COUNT(t.TransactionID) AS
TxCountLast7Days,
    CASE
       WHEN COUNT(t.TransactionID) >= 10 THEN 30
       WHEN COUNT(t.TransactionID) >= 6 THEN 20
       WHEN COUNT(t.TransactionID) >= 3 THEN 10
        ELSE 0
     END AS FrequencyRiskScore
    FROM dbo.Transactions_table t
    WHERE t.TransactionDate >= DATEADD(day, -7, GETDATE())
    GROUP BY t.ClientID
)
--Amount risk: Based on total transaction amount in last 7 days--
,Amount7DaysRisk AS (
    SELECT
      t.ClientID,
      SUM(t.Amount) AS TotalAmountLast7Days,

    CASE
       WHEN SUM(t.Amount) >= 50000 THEN 20
       WHEN SUM(t.Amount) >= 25000 THEN 15
       WHEN SUM(t.Amount) >= 10000 THEN 10
         ELSE 0
     END AS Amount7DaysRiskScore
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
TransactionTypeRiskScore AS (
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
)
--Final risk score calculation: combines all risk indicators into Total risk score--
SELECT
     cr.ClientID,
     cr.Name,
     cr.Country,
     cr.CountryRiskScore,
     ISNULL(fr.FrequencyRiskScore, 0) 
  AS FrequencyRiskScore,
     ISNULL(a7.Amount7DaysRiskScore, 0)
  AS Amount7DaysRiskScore,
     ISNULL(st.SingleTxAmountRiskScore, 0)
  AS SingleTxAmountRiskScore,
     ISNULL(tt.TransactionTypeRiskScore, 0)
  AS TransactionTypeRiskScore,

    cr.CountryRiskScore
    + ISNULL(fr.FrequencyRiskScore, 0)
    + ISNULL(a7.Amount7DaysRiskScore, 0)
    + ISNULL(st.SingleTxAmountRiskScore, 0)
    + ISNULL(tt.TransactionTypeRiskScore, 0)
AS TotalRiskScore
  FROM CountryRisk cr
  LEFT JOIN FrequencyRisk fr
      ON cr.ClientID = fr.ClientID
  LEFT JOIN Amount7DaysRisk a7
      ON cr.ClientID = a7.ClientID
  LEFT JOIN SingleTxAmountRisk st
      ON cr.ClientID = st.ClientID
  LEFT JOIN TransactionTypeRiskScore tt
      ON cr.ClientID = tt.ClientID