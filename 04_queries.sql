/*Risk scoring engine: calculates client risk score based on country risk rules and maps
the score to a risk level*/
SELECT
    s.ClientID,
    s.Name,
    s.Country,
    s.RiskScore,
    rl.RiskLevelName
FROM (
    SELECT
       c.ClientID,
       c.Name,
       c.Country,
       SUM(r.Points) as RiskScore
    FROM dbo.Clients_table c
    JOIN dbo.riskrules_table r
       ON c.Country = r.RuleValue
WHERE r.RuleType = 'Country'
 AND r.IsActive = 1
GROUP BY
    c.ClientID,
    c.name,
    c.Country
) s
JOIN dbo.RiskLevels_table rl
    ON s.RiskScore BETWEEN rl.MinScore
AND rl.MaxScore;

--Frequency risk scoring: Calculates client frequency score based on transactions in last 7 days-
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

--Amount risk scoring: Total transaction amount per client in last 7 days--
SELECT
    ClientID,
    SUM(t.Amount) AS
TotalAmountLast7Days,
    CASE
       WHEN SUM(t.Amount) >= 50000 THEN 20
       WHEN SUM(t.Amount) >= 25000 THEN 15
       WHEN SUM(t.Amount) >= 10000 THEN 10
         ELSE 0
     END AS AmountRiskScore
    FROM dbo.Transactions_table t
    WHERE t.TransactionDate >= DATEADD(day, -7, GETDATE())
    GROUP BY t.ClientID
--Amount risk scoring query: Risk points based on single transaction amount--
SELECT
    t.TransactionID,
    t.ClientID,
    t.Amount,
       CASE
          WHEN t.Amount >= 10000 THEN 10
          WHEN t.Amount >= 5000 THEN 6
          WHEN t.Amount >= 2000 THEN 3
           ELSE 0
         END AS SingleTxAmountRiskScore
       FROM dbo.Transactions_table t;

--Transaction type risk scoring query: Risk points based on Transaction type--
SELECT
    t.TransactionID,
    t.clientID,
    tt.TransactionTypeName,

        CASE
          WHEN tt.TransactionTypeName = 'Cripto Transfer' THEN 15
          WHEN tt.TransactionTypeName = 'Cash Withdraval' THEN 10
          WHEN tt.TransactionTypeName = 'ATM Withdraval' THEN 6
          WHEN tt.TransactionTypeName = 'International Transfer' THEN 12
          WHEN tt.TransactionTypeName = 'Domestic Transfer' THEN 4
          WHEN tt.TransactionTypeName = 'Card Payment' THEN 2
          WHEN tt.TransactionTypeName = 'Cash Deposit' THEN 8
           ELSE 0
           END AS TransactionTypeRiskScore
        FROM dbo.Transactions_table t
        JOIN dbo.TransactionType_table tt
        ON t.TransactionTypeID = tt.TransactionTypeID

