-- =========================================
-- Telco Customer Churn — SQL Analysis
-- Matches actual columns from the IBM Telco dataset
-- =========================================

CREATE TABLE main_data (
    CustomerID VARCHAR(20) PRIMARY KEY,
    City VARCHAR(50),
    State VARCHAR(50),
    Gender VARCHAR(10),
    SeniorCitizen VARCHAR(5),
    TenureMonths INT,
    Contract VARCHAR(20),
    PaymentMethod VARCHAR(30),
    MonthlyCharges DECIMAL(10,2),
    TotalCharges DECIMAL(10,2),
    ChurnLabel VARCHAR(5),
    ChurnScore INT,
    CLTV INT,
    ChurnReason VARCHAR(100)
);

CREATE TABLE location_data (
    LocationID VARCHAR(20),
    CustomerID VARCHAR(20),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(10),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6)
);

CREATE TABLE services_data (
    ServiceID VARCHAR(20),
    CustomerID VARCHAR(20),
    InternetType VARCHAR(20),
    Offer VARCHAR(20),
    StreamingTV VARCHAR(10),
    PremiumTechSupport VARCHAR(10),
    TotalRevenue DECIMAL(10,2)
);

CREATE TABLE status_data (
    StatusID VARCHAR(20),
    CustomerID VARCHAR(20),
    SatisfactionScore INT,
    CustomerStatus VARCHAR(20),
    ChurnCategory VARCHAR(30),
    ChurnReason VARCHAR(100)
);

-- 1. Overall churn rate
SELECT ChurnLabel, COUNT(*) AS Customers,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM main_data), 2) AS Pct
FROM main_data
GROUP BY ChurnLabel;

-- 2. Churn rate by Contract type
SELECT Contract,
       COUNT(*) AS Total,
       SUM(CASE WHEN ChurnLabel = 'Yes' THEN 1 ELSE 0 END) AS Churned,
       ROUND(SUM(CASE WHEN ChurnLabel = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ChurnRatePct
FROM main_data
GROUP BY Contract
ORDER BY ChurnRatePct DESC;

-- 3. Top 10 cities by churn rate
SELECT City,
       COUNT(*) AS TotalCustomers,
       SUM(CASE WHEN ChurnLabel = 'Yes' THEN 1 ELSE 0 END) AS Churned,
       ROUND(SUM(CASE WHEN ChurnLabel = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ChurnRatePct
FROM main_data
GROUP BY City
HAVING COUNT(*) > 20
ORDER BY ChurnRatePct DESC
LIMIT 10;

-- 4. Churn reason breakdown (from status table)
SELECT s.ChurnCategory, s.ChurnReason, COUNT(*) AS Customers
FROM status_data s
WHERE s.CustomerStatus = 'Churned'
GROUP BY s.ChurnCategory, s.ChurnReason
ORDER BY Customers DESC;

-- 5. Average tenure and charges: churned vs retained
SELECT ChurnLabel,
       ROUND(AVG(TenureMonths), 1) AS AvgTenure,
       ROUND(AVG(MonthlyCharges), 2) AS AvgMonthlyCharges,
       ROUND(AVG(CLTV), 0) AS AvgCLTV
FROM main_data
GROUP BY ChurnLabel;

-- 6. Impact of Internet Type on churn (join with services)
SELECT sv.InternetType,
       COUNT(*) AS Total,
       SUM(CASE WHEN m.ChurnLabel = 'Yes' THEN 1 ELSE 0 END) AS Churned,
       ROUND(SUM(CASE WHEN m.ChurnLabel = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ChurnRatePct
FROM main_data m
JOIN services_data sv ON m.CustomerID = sv.CustomerID
GROUP BY sv.InternetType
ORDER BY ChurnRatePct DESC;

-- 7. Rank customers by CLTV within churned group (window function)
SELECT CustomerID, CLTV,
       RANK() OVER (ORDER BY CLTV DESC) AS CLTVRank
FROM main_data
WHERE ChurnLabel = 'Yes';

-- 8. Monthly charge tier vs churn rate (CASE bucketing + window)
SELECT
    CASE
        WHEN MonthlyCharges < 35 THEN 'Low (<35)'
        WHEN MonthlyCharges < 70 THEN 'Medium (35-70)'
        ELSE 'High (70+)'
    END AS ChargeTier,
    COUNT(*) AS Total,
    SUM(CASE WHEN ChurnLabel = 'Yes' THEN 1 ELSE 0 END) AS Churned,
    ROUND(SUM(CASE WHEN ChurnLabel = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ChurnRatePct
FROM main_data
GROUP BY ChargeTier
ORDER BY ChurnRatePct DESC;

-- 9. Reporting view for Power BI
CREATE VIEW vw_churn_summary AS
SELECT m.CustomerID, m.Contract, m.TenureMonths, m.MonthlyCharges, m.TotalCharges,
       m.ChurnLabel, m.ChurnScore, m.CLTV,
       l.City, l.State, l.Latitude, l.Longitude,
       sv.InternetType, sv.Offer,
       st.SatisfactionScore, st.CustomerStatus, st.ChurnCategory, st.ChurnReason
FROM main_data m
LEFT JOIN location_data l ON m.CustomerID = l.CustomerID
LEFT JOIN services_data sv ON m.CustomerID = sv.CustomerID
LEFT JOIN status_data st ON m.CustomerID = st.CustomerID;
