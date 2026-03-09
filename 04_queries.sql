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