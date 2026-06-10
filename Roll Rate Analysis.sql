---------------------------------xxxxxxxxxxxxxxxxxxxxxRoll Rate Data Flow xxxxxxxxxxxxxxxxxxxxxx----------------------------------------
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
   STC.Name AS selltoCustomerName,
     DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) AS Age,
      BTC.[Customer Posting Group], 
          BTC.[Bill-to Customer No_],
       BTC.Name as billtocustomername, 
       STC.[Blocked],
       case when STC.[Blocked] in ( '0','') then 'Active'
            --when STC.[Blocked] in ( '1','2','3')
            else 'Blocked'
            end as [Blocked Status],
    --BTC.[Responsibility Center],
    CASE 
    WHEN CLE.[Global Dimension 1 Code] = 0 THEN 'NA'
    WHEN CLE.[Global Dimension 1 Code] = 1 THEN 'Louisville'
    WHEN CLE.[Global Dimension 1 Code] = 2 THEN 'Columbus (NPDI)'
    WHEN CLE.[Global Dimension 1 Code] = 3 THEN 'Indianapolis'
    WHEN CLE.[Global Dimension 1 Code] = 4 THEN 'Dayton'
    WHEN CLE.[Global Dimension 1 Code] = 5 THEN 'Lexington'
    WHEN CLE.[Global Dimension 1 Code] = 6 THEN 'Cincinnati'
    WHEN CLE.[Global Dimension 1 Code] = 7 THEN 'Evansville'
    WHEN CLE.[Global Dimension 1 Code] = 8 THEN 'West Virginia'
    WHEN CLE.[Global Dimension 1 Code] = 9 THEN 'Erlanger'
    WHEN CLE.[Global Dimension 1 Code] = 10 THEN 'Warehouse Solutions'
    WHEN CLE.[Global Dimension 1 Code] = 11 THEN 'Tire Central'
    WHEN CLE.[Global Dimension 1 Code] = 14 THEN 'TMMK'
    WHEN CLE.[Global Dimension 1 Code] = 15 THEN 'TMMWV'
    WHEN CLE.[Global Dimension 1 Code] = 20 THEN 'Specialty Products'
    WHEN CLE.[Global Dimension 1 Code] = 21 THEN 'Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 31 THEN 'Cleveland'
    WHEN CLE.[Global Dimension 1 Code] = 32 THEN 'Toledo'
    WHEN CLE.[Global Dimension 1 Code] = 33 THEN 'Columbus OH'
    WHEN CLE.[Global Dimension 1 Code] = 39 THEN 'TMH Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 40 THEN 'TRANSIT'
    ELSE 'Unknown'
END AS CSC_Name, 
    CLE.[Sell-to Customer No_], 
    CLE.[Global Dimension 2 Code] as ProfitCenterNo,
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance, 
    
    -- Updated Aging Buckets
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) < 0) AS [Not Due], 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 0 AND 30) AS [0-30 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 31 AND 60) AS [31-60 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 61 AND 90) AS [61-90 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 91 AND 120) AS [91-120 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 121 AND 150) AS [121-150 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 151 AND 180) AS [151-180 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 181 AND 210) AS [181-210 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 211 AND 240) AS [211-240 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 241 AND 270) AS [241-270 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 271 AND 300) AS [271-300 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 301 AND 330) AS [301-330 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 331 AND 365) AS [331-365 Days],

(SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) >  365) AS [365+ Days]

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= CONVERT(Date, DATEADD(DAY, -1, { fn NOW() })) 
    AND BTC.[Customer Posting Group] = 'TRADE'
;





------------------------xxxxxxxxxxxxxxxxxxxxxxxSTORED PROCEDURE TO CALCULATE ROLL RATES-----------------------------
ALTER PROCEDURE usp_GetARAgingBalances
    @StartSnapshotDate DATE,
    @EndSnapshotDate DATE
AS
BEGIN
    DECLARE @StartSnapshotView NVARCHAR(100) = 'vw_Customer_Ledger_Snapshot_' + CONVERT(CHAR(8), @StartSnapshotDate, 112);
    DECLARE @EndSnapshotView NVARCHAR(100) = 'vw_Customer_Ledger_Snapshot_' + CONVERT(CHAR(8), @EndSnapshotDate, 112);

    DECLARE @SQL NVARCHAR(MAX) = N'
    WITH StartUnpivot AS (
        SELECT AgingBucket, Balance
        FROM (
            SELECT 
                [Not Due], [0-30 Days], [31-60 Days], [61-90 Days],
                [91-120 Days], [121-180 Days], [181-365 Days], [>365 Days]
            FROM ' + QUOTENAME(@StartSnapshotView) + '
        ) AS SourceTbl
        UNPIVOT (
            Balance FOR AgingBucket IN (
                [Not Due], [0-30 Days], [31-60 Days], [61-90 Days],
                [91-120 Days], [121-180 Days], [181-365 Days], [>365 Days]
            )
        ) AS unpvt
    ),
    EndUnpivot AS (
        SELECT AgingBucket, Balance
        FROM (
            SELECT 
                [Not Due], [0-30 Days], [31-60 Days], [61-90 Days],
                [91-120 Days], [121-180 Days], [181-365 Days], [>365 Days]
            FROM ' + QUOTENAME(@EndSnapshotView) + '
        ) AS SourceTbl
        UNPIVOT (
            Balance FOR AgingBucket IN (
                [Not Due], [0-30 Days], [31-60 Days], [61-90 Days],
                [91-120 Days], [121-180 Days], [181-365 Days], [>365 Days]
            )
        ) AS unpvt
    ),
    StartSums AS (
        SELECT AgingBucket, SUM(Balance) AS StartBalance
        FROM StartUnpivot
        GROUP BY AgingBucket
    ),
    EndSums AS (
        SELECT AgingBucket, SUM(Balance) AS EndBalance
        FROM EndUnpivot
        GROUP BY AgingBucket
    )
    SELECT 
        COALESCE(S.AgingBucket, E.AgingBucket) AS AgingBucket,
        ISNULL(S.StartBalance, 0) AS [' + CONVERT(CHAR(10), @StartSnapshotDate, 120) + ' Balance],
        ISNULL(E.EndBalance, 0) AS [' + CONVERT(CHAR(10), @EndSnapshotDate, 120) + ' Balance]
    FROM StartSums S
    FULL OUTER JOIN EndSums E ON S.AgingBucket = E.AgingBucket
    ORDER BY 
        CASE COALESCE(S.AgingBucket, E.AgingBucket)
            WHEN ''Not Due'' THEN 1
            WHEN ''0-30 Days'' THEN 2
            WHEN ''31-60 Days'' THEN 3
            WHEN ''61-90 Days'' THEN 4
            WHEN ''91-120 Days'' THEN 5
            WHEN ''121-180 Days'' THEN 6
            WHEN ''181-365 Days'' THEN 7
            WHEN ''>365 Days'' THEN 8
            ELSE 9
        END;
    '

    EXEC sp_executesql @SQL
END




-----EXECUTION QUERY-----
EXEC usp_GetARRollRates 
    @StartSnapshotDate = '2025-03-31',
    @EndSnapshotDate = '2025-04-30'

-----------

-------------------------------------------------END----------------------------------------------------------------------

SELECT top 10 * 
FROM dbo.vw_Customer_Ledger_Snapshot_20250331
--dbo.vw_Customer_Ledger_Snapshot_20250430


--
SELECT *
-- CAST(('2025-03-31') AS DATE) AS SnapshotDate
FROM dbo.vw_Customer_Ledger_Snapshot_20250331

UNION ALL

SELECT *
--CAST('2025-04-30' AS DATE) AS SnapshotDate
FROM dbo.vw_Customer_Ledger_Snapshot_20250430

UNION ALL

SELECT *
--CAST('2025-02-28' AS DATE) AS SnapshotDate
FROM dbo.vw_Customer_Ledger_Snapshot_20250228

UNION ALL

SELECT *
-- CAST('2025-01-31' AS DATE) AS SnapshotDate
FROM dbo.vw_Customer_Ledger_Snapshot_20250131

UNION ALL

SELECT *
--CAST('2024-12-31' AS DATE) AS SnapshotDate
FROM dbo.vw_Customer_Ledger_Snapshot_20241231

--


---------------------------- Check the view table and Create View vw_Customer_Ledger_Snapshot_20250331---------------------------------------------------------
--1

GO
CREATE VIEW dbo.vw_Customer_Ledger_Snapshot_20241231 AS
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    --STC.Name AS selltoCustomerName,
    --STC.[Latitude],
    --STC.[Longitude], 
    --BTC.[Bill-to Customer No_],
   -- BTC.Name AS billtocustomername, 
    --STC.[Blocked],
    --CASE 
        --WHEN STC.[Blocked] IN ('0','') THEN 'Active'
        --ELSE 'Blocked'
    --END AS [Blocked Status],
    --STC.[Blocked Reason],

   /** CASE CLE.[Document Type] 
        WHEN 0 THEN 'Transfer' 
        WHEN 1 THEN 'Payment' 
        WHEN 2 THEN 'Invoice' 
        WHEN 3 THEN 'Credit Memo' 
        WHEN 4 THEN 'Finance Charge Memo' 
        WHEN 5 THEN 'Reminder' 
        WHEN 6 THEN 'Refund' 
        ELSE '' 
    END AS Cust__Ledger_EntryDocumentType, **/

    --CLE.[Document No_] AS Cust__Ledger_EntryDocumentNo_, 
    --CLE.Description AS Cust__Ledger_EntryDescription, 
    --CLE.[Posting Date] AS Cust__Ledger_EntryPostingDate, 
    CLE.[Entry No_] AS Cust__Ledger_EntryEntryNo_, -- CLE.[Entry No_] = '106682976'
    --CLE.[Global Dimension 1 Code] AS CSC,

    /**CASE CLE.[ELC Doc_ Type] 
        WHEN 0 THEN ' ' 
        WHEN 1 THEN 'Rental Contract' 
        WHEN 2 THEN 'Work Order' 
        WHEN 3 THEN 'Equipment Configurator' 
        WHEN 4 THEN 'Purchase Configurator' 
        WHEN 5 THEN 'Parts' 
        WHEN 6 THEN 'Maintenance Contract' 
        WHEN 7 THEN 'Project' 
        WHEN 8 THEN 'Cons. Order' 
        WHEN 9 THEN 'Financing' 
        WHEN 10 THEN 'Item Contract' 
        ELSE '' 
    END AS Cust__Ledger_EntryELCDoc_Type, **/
    
    -- Remaining Amount (Total Balance)
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance, 

    -- Aging Reference Date
    --DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') AS Age, 

    --BTC.[Customer Posting Group], 
    --BTC.[Responsibility Center],

    -- CSC Name
   /** CASE 
    WHEN CLE.[Global Dimension 1 Code] = 0 THEN 'NA'
    WHEN CLE.[Global Dimension 1 Code] = 1 THEN 'Louisville'
    WHEN CLE.[Global Dimension 1 Code] = 2 THEN 'Columbus (NPDI)'
    WHEN CLE.[Global Dimension 1 Code] = 3 THEN 'Indianapolis'
    WHEN CLE.[Global Dimension 1 Code] = 4 THEN 'Dayton'
    WHEN CLE.[Global Dimension 1 Code] = 5 THEN 'Lexington'
    WHEN CLE.[Global Dimension 1 Code] = 6 THEN 'Cincinnati'
    WHEN CLE.[Global Dimension 1 Code] = 7 THEN 'Evansville'
    WHEN CLE.[Global Dimension 1 Code] = 8 THEN 'West Virginia'
    WHEN CLE.[Global Dimension 1 Code] = 9 THEN 'Erlanger'
    WHEN CLE.[Global Dimension 1 Code] = 10 THEN 'Warehouse Solutions'
    WHEN CLE.[Global Dimension 1 Code] = 11 THEN 'Tire Central'
    WHEN CLE.[Global Dimension 1 Code] = 14 THEN 'TMMK'
    WHEN CLE.[Global Dimension 1 Code] = 15 THEN 'TMMWV'
    WHEN CLE.[Global Dimension 1 Code] = 20 THEN 'Specialty Products'
    WHEN CLE.[Global Dimension 1 Code] = 21 THEN 'Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 31 THEN 'Cleveland'
    WHEN CLE.[Global Dimension 1 Code] = 32 THEN 'Toledo'
    WHEN CLE.[Global Dimension 1 Code] = 33 THEN 'Columbus OH'
    WHEN CLE.[Global Dimension 1 Code] = 39 THEN 'TMH Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 40 THEN 'TRANSIT'
    ELSE 'Unknown'
END AS CSC_Name, **/

    --CLE.[Sell-to Customer No_], 
    --CLE.[Global Dimension 2 Code] AS ProfitCenterNo,
    --RCH.[Contract Type], 
    --STC.[Payment Method Code], 
    --CLE.[Dispute Code], 
    --CLE.[External Document No_], 
    --CLE.[Salesperson Code], 
    --STC.[External Document No_ Required] AS [PO Req], 
    --RCH.[Document Type], 

    -- Comments Flag
   /** CASE 
        (SELECT COUNT(No_) 
         FROM [Production$Comment Line] 
         WHERE CLE.[Document No_] = No_) 
        WHEN 0 THEN 'NO' 
        ELSE 'YES' 
    END AS Comments, **/
    
    --CLE.[Due Date], 
    --BTC.[Territory Code], 
    --BTC.[Collection Method], 
    --BTC.[Payment Terms Code], 
    --BTC.Rating,

    -- Aging Buckets
    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2024-12-31') < 0) AS [Not Due],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2024-12-31') BETWEEN 0 AND 30) AS [0-30 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2024-12-31') BETWEEN 31 AND 60) AS [31-60 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2024-12-31') BETWEEN 61 AND 90) AS [61-90 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2024-12-31') BETWEEN 91 AND 120) AS [91-120 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2024-12-31') BETWEEN 121 AND 180) AS [121-180 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2024-12-31') BETWEEN 181 AND 365) AS [181-365 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2024-12-31') > 365) AS [>365 Days],

    -- Snapshot Date
    '2024-12-31' AS AgeAsOf

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= '2024-12-31'
    AND BTC.[Customer Posting Group] = 'TRADE' AND CLE.[Entry No_] = '106682976';

go


--2
GO
CREATE VIEW dbo.vw_Customer_Ledger_Snapshot_20250131 AS
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    --STC.Name AS selltoCustomerName,
    --STC.[Latitude],
    --STC.[Longitude], 
    --BTC.[Bill-to Customer No_],
   -- BTC.Name AS billtocustomername, 
    --STC.[Blocked],
    --CASE 
        --WHEN STC.[Blocked] IN ('0','') THEN 'Active'
        --ELSE 'Blocked'
    --END AS [Blocked Status],
    --STC.[Blocked Reason],

   /** CASE CLE.[Document Type] 
        WHEN 0 THEN 'Transfer' 
        WHEN 1 THEN 'Payment' 
        WHEN 2 THEN 'Invoice' 
        WHEN 3 THEN 'Credit Memo' 
        WHEN 4 THEN 'Finance Charge Memo' 
        WHEN 5 THEN 'Reminder' 
        WHEN 6 THEN 'Refund' 
        ELSE '' 
    END AS Cust__Ledger_EntryDocumentType, **/

    --CLE.[Document No_] AS Cust__Ledger_EntryDocumentNo_, 
    --CLE.Description AS Cust__Ledger_EntryDescription, 
    --CLE.[Posting Date] AS Cust__Ledger_EntryPostingDate, 
    --CLE.[Entry No_] AS Cust__Ledger_EntryEntryNo_, 
    --CLE.[Global Dimension 1 Code] AS CSC,

    /**CASE CLE.[ELC Doc_ Type] 
        WHEN 0 THEN ' ' 
        WHEN 1 THEN 'Rental Contract' 
        WHEN 2 THEN 'Work Order' 
        WHEN 3 THEN 'Equipment Configurator' 
        WHEN 4 THEN 'Purchase Configurator' 
        WHEN 5 THEN 'Parts' 
        WHEN 6 THEN 'Maintenance Contract' 
        WHEN 7 THEN 'Project' 
        WHEN 8 THEN 'Cons. Order' 
        WHEN 9 THEN 'Financing' 
        WHEN 10 THEN 'Item Contract' 
        ELSE '' 
    END AS Cust__Ledger_EntryELCDoc_Type, **/
    
    -- Remaining Amount (Total Balance)
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance, 

    -- Aging Reference Date
    --DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') AS Age, 

    --BTC.[Customer Posting Group], 
    --BTC.[Responsibility Center],

    -- CSC Name
   /** CASE 
    WHEN CLE.[Global Dimension 1 Code] = 0 THEN 'NA'
    WHEN CLE.[Global Dimension 1 Code] = 1 THEN 'Louisville'
    WHEN CLE.[Global Dimension 1 Code] = 2 THEN 'Columbus (NPDI)'
    WHEN CLE.[Global Dimension 1 Code] = 3 THEN 'Indianapolis'
    WHEN CLE.[Global Dimension 1 Code] = 4 THEN 'Dayton'
    WHEN CLE.[Global Dimension 1 Code] = 5 THEN 'Lexington'
    WHEN CLE.[Global Dimension 1 Code] = 6 THEN 'Cincinnati'
    WHEN CLE.[Global Dimension 1 Code] = 7 THEN 'Evansville'
    WHEN CLE.[Global Dimension 1 Code] = 8 THEN 'West Virginia'
    WHEN CLE.[Global Dimension 1 Code] = 9 THEN 'Erlanger'
    WHEN CLE.[Global Dimension 1 Code] = 10 THEN 'Warehouse Solutions'
    WHEN CLE.[Global Dimension 1 Code] = 11 THEN 'Tire Central'
    WHEN CLE.[Global Dimension 1 Code] = 14 THEN 'TMMK'
    WHEN CLE.[Global Dimension 1 Code] = 15 THEN 'TMMWV'
    WHEN CLE.[Global Dimension 1 Code] = 20 THEN 'Specialty Products'
    WHEN CLE.[Global Dimension 1 Code] = 21 THEN 'Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 31 THEN 'Cleveland'
    WHEN CLE.[Global Dimension 1 Code] = 32 THEN 'Toledo'
    WHEN CLE.[Global Dimension 1 Code] = 33 THEN 'Columbus OH'
    WHEN CLE.[Global Dimension 1 Code] = 39 THEN 'TMH Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 40 THEN 'TRANSIT'
    ELSE 'Unknown'
END AS CSC_Name, **/

    --CLE.[Sell-to Customer No_], 
    --CLE.[Global Dimension 2 Code] AS ProfitCenterNo,
    --RCH.[Contract Type], 
    --STC.[Payment Method Code], 
    --CLE.[Dispute Code], 
    --CLE.[External Document No_], 
    --CLE.[Salesperson Code], 
    --STC.[External Document No_ Required] AS [PO Req], 
    --RCH.[Document Type], 

    -- Comments Flag
   /** CASE 
        (SELECT COUNT(No_) 
         FROM [Production$Comment Line] 
         WHERE CLE.[Document No_] = No_) 
        WHEN 0 THEN 'NO' 
        ELSE 'YES' 
    END AS Comments, **/
    
    --CLE.[Due Date], 
    --BTC.[Territory Code], 
    --BTC.[Collection Method], 
    --BTC.[Payment Terms Code], 
    --BTC.Rating,

    -- Aging Buckets
    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-01-31') < 0) AS [Not Due],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-01-31') BETWEEN 0 AND 30) AS [0-30 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-01-31') BETWEEN 31 AND 60) AS [31-60 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-01-31') BETWEEN 61 AND 90) AS [61-90 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-01-31') BETWEEN 91 AND 120) AS [91-120 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-01-31') BETWEEN 121 AND 180) AS [121-180 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-01-31') BETWEEN 181 AND 365) AS [181-365 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-01-31') > 365) AS [>365 Days],

    -- Snapshot Date
    '2025-01-31' AS AgeAsOf

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= '2025-01-31'
    AND BTC.[Customer Posting Group] = 'TRADE';

go

--3

GO
CREATE VIEW dbo.vw_Customer_Ledger_Snapshot_20250228 AS
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    --STC.Name AS selltoCustomerName,
    --STC.[Latitude],
    --STC.[Longitude], 
    --BTC.[Bill-to Customer No_],
   -- BTC.Name AS billtocustomername, 
    --STC.[Blocked],
    --CASE 
        --WHEN STC.[Blocked] IN ('0','') THEN 'Active'
        --ELSE 'Blocked'
    --END AS [Blocked Status],
    --STC.[Blocked Reason],

   /** CASE CLE.[Document Type] 
        WHEN 0 THEN 'Transfer' 
        WHEN 1 THEN 'Payment' 
        WHEN 2 THEN 'Invoice' 
        WHEN 3 THEN 'Credit Memo' 
        WHEN 4 THEN 'Finance Charge Memo' 
        WHEN 5 THEN 'Reminder' 
        WHEN 6 THEN 'Refund' 
        ELSE '' 
    END AS Cust__Ledger_EntryDocumentType, **/

    --CLE.[Document No_] AS Cust__Ledger_EntryDocumentNo_, 
    --CLE.Description AS Cust__Ledger_EntryDescription, 
    --CLE.[Posting Date] AS Cust__Ledger_EntryPostingDate, 
    CLE.[Entry No_] AS Cust__Ledger_EntryEntryNo_, 
    --CLE.[Global Dimension 1 Code] AS CSC,

    /**CASE CLE.[ELC Doc_ Type] 
        WHEN 0 THEN ' ' 
        WHEN 1 THEN 'Rental Contract' 
        WHEN 2 THEN 'Work Order' 
        WHEN 3 THEN 'Equipment Configurator' 
        WHEN 4 THEN 'Purchase Configurator' 
        WHEN 5 THEN 'Parts' 
        WHEN 6 THEN 'Maintenance Contract' 
        WHEN 7 THEN 'Project' 
        WHEN 8 THEN 'Cons. Order' 
        WHEN 9 THEN 'Financing' 
        WHEN 10 THEN 'Item Contract' 
        ELSE '' 
    END AS Cust__Ledger_EntryELCDoc_Type, **/
    
    -- Remaining Amount (Total Balance)
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance, 

    -- Aging Reference Date
    --DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') AS Age, 

    --BTC.[Customer Posting Group], 
    --BTC.[Responsibility Center],

    -- CSC Name
   /** CASE 
    WHEN CLE.[Global Dimension 1 Code] = 0 THEN 'NA'
    WHEN CLE.[Global Dimension 1 Code] = 1 THEN 'Louisville'
    WHEN CLE.[Global Dimension 1 Code] = 2 THEN 'Columbus (NPDI)'
    WHEN CLE.[Global Dimension 1 Code] = 3 THEN 'Indianapolis'
    WHEN CLE.[Global Dimension 1 Code] = 4 THEN 'Dayton'
    WHEN CLE.[Global Dimension 1 Code] = 5 THEN 'Lexington'
    WHEN CLE.[Global Dimension 1 Code] = 6 THEN 'Cincinnati'
    WHEN CLE.[Global Dimension 1 Code] = 7 THEN 'Evansville'
    WHEN CLE.[Global Dimension 1 Code] = 8 THEN 'West Virginia'
    WHEN CLE.[Global Dimension 1 Code] = 9 THEN 'Erlanger'
    WHEN CLE.[Global Dimension 1 Code] = 10 THEN 'Warehouse Solutions'
    WHEN CLE.[Global Dimension 1 Code] = 11 THEN 'Tire Central'
    WHEN CLE.[Global Dimension 1 Code] = 14 THEN 'TMMK'
    WHEN CLE.[Global Dimension 1 Code] = 15 THEN 'TMMWV'
    WHEN CLE.[Global Dimension 1 Code] = 20 THEN 'Specialty Products'
    WHEN CLE.[Global Dimension 1 Code] = 21 THEN 'Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 31 THEN 'Cleveland'
    WHEN CLE.[Global Dimension 1 Code] = 32 THEN 'Toledo'
    WHEN CLE.[Global Dimension 1 Code] = 33 THEN 'Columbus OH'
    WHEN CLE.[Global Dimension 1 Code] = 39 THEN 'TMH Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 40 THEN 'TRANSIT'
    ELSE 'Unknown'
END AS CSC_Name, **/

    --CLE.[Sell-to Customer No_], 
    --CLE.[Global Dimension 2 Code] AS ProfitCenterNo,
    --RCH.[Contract Type], 
    --STC.[Payment Method Code], 
    --CLE.[Dispute Code], 
    --CLE.[External Document No_], 
    --CLE.[Salesperson Code], 
    --STC.[External Document No_ Required] AS [PO Req], 
    --RCH.[Document Type], 

    -- Comments Flag
   /** CASE 
        (SELECT COUNT(No_) 
         FROM [Production$Comment Line] 
         WHERE CLE.[Document No_] = No_) 
        WHEN 0 THEN 'NO' 
        ELSE 'YES' 
    END AS Comments, **/
    
    CLE.[Due Date], 
    --BTC.[Territory Code], 
    --BTC.[Collection Method], 
    --BTC.[Payment Terms Code], 
    --BTC.Rating,

    -- Aging Buckets
    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-02-28') < 0) AS [Not Due],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-02-28') BETWEEN 0 AND 30) AS [0-30 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-02-28') BETWEEN 31 AND 60) AS [31-60 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-02-28') BETWEEN 61 AND 90) AS [61-90 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-02-28') BETWEEN 91 AND 120) AS [91-120 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-02-28') BETWEEN 121 AND 180) AS [121-180 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-02-28') BETWEEN 181 AND 365) AS [181-365 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-02-28') > 365) AS [>365 Days],

    -- Snapshot Date
    '2025-02-28' AS AgeAsOf

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= '2025-02-28'
    AND BTC.[Customer Posting Group] = 'TRADE'
    --AND CLE.[Entry No_] = '106682976'
    ;

go


--

--

--4

GO
CREATE VIEW dbo.vw_Customer_Ledger_Snapshot_20250331 AS
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    --STC.Name AS selltoCustomerName,
    --STC.[Latitude],
    --STC.[Longitude], 
    --BTC.[Bill-to Customer No_],
   -- BTC.Name AS billtocustomername, 
    --STC.[Blocked],
    --CASE 
        --WHEN STC.[Blocked] IN ('0','') THEN 'Active'
        --ELSE 'Blocked'
    --END AS [Blocked Status],
    --STC.[Blocked Reason],

   /** CASE CLE.[Document Type] 
        WHEN 0 THEN 'Transfer' 
        WHEN 1 THEN 'Payment' 
        WHEN 2 THEN 'Invoice' 
        WHEN 3 THEN 'Credit Memo' 
        WHEN 4 THEN 'Finance Charge Memo' 
        WHEN 5 THEN 'Reminder' 
        WHEN 6 THEN 'Refund' 
        ELSE '' 
    END AS Cust__Ledger_EntryDocumentType, **/

    --CLE.[Document No_] AS Cust__Ledger_EntryDocumentNo_, 
    --CLE.Description AS Cust__Ledger_EntryDescription, 
    --CLE.[Posting Date] AS Cust__Ledger_EntryPostingDate, 
    --CLE.[Entry No_] AS Cust__Ledger_EntryEntryNo_, 
    --CLE.[Global Dimension 1 Code] AS CSC,

    /**CASE CLE.[ELC Doc_ Type] 
        WHEN 0 THEN ' ' 
        WHEN 1 THEN 'Rental Contract' 
        WHEN 2 THEN 'Work Order' 
        WHEN 3 THEN 'Equipment Configurator' 
        WHEN 4 THEN 'Purchase Configurator' 
        WHEN 5 THEN 'Parts' 
        WHEN 6 THEN 'Maintenance Contract' 
        WHEN 7 THEN 'Project' 
        WHEN 8 THEN 'Cons. Order' 
        WHEN 9 THEN 'Financing' 
        WHEN 10 THEN 'Item Contract' 
        ELSE '' 
    END AS Cust__Ledger_EntryELCDoc_Type, **/
    
    -- Remaining Amount (Total Balance)
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance, 

    -- Aging Reference Date
    --DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') AS Age, 

    --BTC.[Customer Posting Group], 
    --BTC.[Responsibility Center],

    -- CSC Name
   /** CASE 
    WHEN CLE.[Global Dimension 1 Code] = 0 THEN 'NA'
    WHEN CLE.[Global Dimension 1 Code] = 1 THEN 'Louisville'
    WHEN CLE.[Global Dimension 1 Code] = 2 THEN 'Columbus (NPDI)'
    WHEN CLE.[Global Dimension 1 Code] = 3 THEN 'Indianapolis'
    WHEN CLE.[Global Dimension 1 Code] = 4 THEN 'Dayton'
    WHEN CLE.[Global Dimension 1 Code] = 5 THEN 'Lexington'
    WHEN CLE.[Global Dimension 1 Code] = 6 THEN 'Cincinnati'
    WHEN CLE.[Global Dimension 1 Code] = 7 THEN 'Evansville'
    WHEN CLE.[Global Dimension 1 Code] = 8 THEN 'West Virginia'
    WHEN CLE.[Global Dimension 1 Code] = 9 THEN 'Erlanger'
    WHEN CLE.[Global Dimension 1 Code] = 10 THEN 'Warehouse Solutions'
    WHEN CLE.[Global Dimension 1 Code] = 11 THEN 'Tire Central'
    WHEN CLE.[Global Dimension 1 Code] = 14 THEN 'TMMK'
    WHEN CLE.[Global Dimension 1 Code] = 15 THEN 'TMMWV'
    WHEN CLE.[Global Dimension 1 Code] = 20 THEN 'Specialty Products'
    WHEN CLE.[Global Dimension 1 Code] = 21 THEN 'Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 31 THEN 'Cleveland'
    WHEN CLE.[Global Dimension 1 Code] = 32 THEN 'Toledo'
    WHEN CLE.[Global Dimension 1 Code] = 33 THEN 'Columbus OH'
    WHEN CLE.[Global Dimension 1 Code] = 39 THEN 'TMH Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 40 THEN 'TRANSIT'
    ELSE 'Unknown'
END AS CSC_Name, **/

    --CLE.[Sell-to Customer No_], 
    --CLE.[Global Dimension 2 Code] AS ProfitCenterNo,
    --RCH.[Contract Type], 
    --STC.[Payment Method Code], 
    --CLE.[Dispute Code], 
    --CLE.[External Document No_], 
    --CLE.[Salesperson Code], 
    --STC.[External Document No_ Required] AS [PO Req], 
    --RCH.[Document Type], 

    -- Comments Flag
   /** CASE 
        (SELECT COUNT(No_) 
         FROM [Production$Comment Line] 
         WHERE CLE.[Document No_] = No_) 
        WHEN 0 THEN 'NO' 
        ELSE 'YES' 
    END AS Comments, **/
    
    --CLE.[Due Date], 
    --BTC.[Territory Code], 
    --BTC.[Collection Method], 
    --BTC.[Payment Terms Code], 
    --BTC.Rating,

    -- Aging Buckets
    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-03-31') < 0) AS [Not Due],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-03-31') BETWEEN 0 AND 30) AS [0-30 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-03-31') BETWEEN 31 AND 60) AS [31-60 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-03-31') BETWEEN 61 AND 90) AS [61-90 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-03-31') BETWEEN 91 AND 120) AS [91-120 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-03-31') BETWEEN 121 AND 180) AS [121-180 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-03-31') BETWEEN 181 AND 365) AS [181-365 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-03-31') > 365) AS [>365 Days],

    -- Snapshot Date
    '2025-03-31'  AS AgeAsOf

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= '2025-03-31'
    AND BTC.[Customer Posting Group] = 'TRADE';

go


--5


--test
--select top 10 * from dbo.vw_Customer_Ledger_Snapshot_20250331
--
GO
ALTER VIEW dbo.vw_Customer_Ledger_Snapshot_20250430 AS
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    --STC.Name AS selltoCustomerName,
    --STC.[Latitude],
    --STC.[Longitude], 
    --BTC.[Bill-to Customer No_],
   -- BTC.Name AS billtocustomername, 
    --STC.[Blocked],
    --CASE 
        --WHEN STC.[Blocked] IN ('0','') THEN 'Active'
        --ELSE 'Blocked'
    --END AS [Blocked Status],
    --STC.[Blocked Reason],

   /** CASE CLE.[Document Type] 
        WHEN 0 THEN 'Transfer' 
        WHEN 1 THEN 'Payment' 
        WHEN 2 THEN 'Invoice' 
        WHEN 3 THEN 'Credit Memo' 
        WHEN 4 THEN 'Finance Charge Memo' 
        WHEN 5 THEN 'Reminder' 
        WHEN 6 THEN 'Refund' 
        ELSE '' 
    END AS Cust__Ledger_EntryDocumentType, **/

    --CLE.[Document No_] AS Cust__Ledger_EntryDocumentNo_, 
    --CLE.Description AS Cust__Ledger_EntryDescription, 
    --CLE.[Posting Date] AS Cust__Ledger_EntryPostingDate, 
    --CLE.[Entry No_] AS Cust__Ledger_EntryEntryNo_, 
    --CLE.[Global Dimension 1 Code] AS CSC,

    /**CASE CLE.[ELC Doc_ Type] 
        WHEN 0 THEN ' ' 
        WHEN 1 THEN 'Rental Contract' 
        WHEN 2 THEN 'Work Order' 
        WHEN 3 THEN 'Equipment Configurator' 
        WHEN 4 THEN 'Purchase Configurator' 
        WHEN 5 THEN 'Parts' 
        WHEN 6 THEN 'Maintenance Contract' 
        WHEN 7 THEN 'Project' 
        WHEN 8 THEN 'Cons. Order' 
        WHEN 9 THEN 'Financing' 
        WHEN 10 THEN 'Item Contract' 
        ELSE '' 
    END AS Cust__Ledger_EntryELCDoc_Type, **/
    
    -- Remaining Amount (Total Balance)
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance, 

    -- Aging Reference Date
    --DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') AS Age, 

    --BTC.[Customer Posting Group], 
    --BTC.[Responsibility Center],

    -- CSC Name
   /** CASE 
    WHEN CLE.[Global Dimension 1 Code] = 0 THEN 'NA'
    WHEN CLE.[Global Dimension 1 Code] = 1 THEN 'Louisville'
    WHEN CLE.[Global Dimension 1 Code] = 2 THEN 'Columbus (NPDI)'
    WHEN CLE.[Global Dimension 1 Code] = 3 THEN 'Indianapolis'
    WHEN CLE.[Global Dimension 1 Code] = 4 THEN 'Dayton'
    WHEN CLE.[Global Dimension 1 Code] = 5 THEN 'Lexington'
    WHEN CLE.[Global Dimension 1 Code] = 6 THEN 'Cincinnati'
    WHEN CLE.[Global Dimension 1 Code] = 7 THEN 'Evansville'
    WHEN CLE.[Global Dimension 1 Code] = 8 THEN 'West Virginia'
    WHEN CLE.[Global Dimension 1 Code] = 9 THEN 'Erlanger'
    WHEN CLE.[Global Dimension 1 Code] = 10 THEN 'Warehouse Solutions'
    WHEN CLE.[Global Dimension 1 Code] = 11 THEN 'Tire Central'
    WHEN CLE.[Global Dimension 1 Code] = 14 THEN 'TMMK'
    WHEN CLE.[Global Dimension 1 Code] = 15 THEN 'TMMWV'
    WHEN CLE.[Global Dimension 1 Code] = 20 THEN 'Specialty Products'
    WHEN CLE.[Global Dimension 1 Code] = 21 THEN 'Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 31 THEN 'Cleveland'
    WHEN CLE.[Global Dimension 1 Code] = 32 THEN 'Toledo'
    WHEN CLE.[Global Dimension 1 Code] = 33 THEN 'Columbus OH'
    WHEN CLE.[Global Dimension 1 Code] = 39 THEN 'TMH Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 40 THEN 'TRANSIT'
    ELSE 'Unknown'
END AS CSC_Name, **/

    --CLE.[Sell-to Customer No_], 
    --CLE.[Global Dimension 2 Code] AS ProfitCenterNo,
    --RCH.[Contract Type], 
    --STC.[Payment Method Code], 
    --CLE.[Dispute Code], 
    --CLE.[External Document No_], 
    --CLE.[Salesperson Code], 
    --STC.[External Document No_ Required] AS [PO Req], 
    --RCH.[Document Type], 

    -- Comments Flag
   /** CASE 
        (SELECT COUNT(No_) 
         FROM [Production$Comment Line] 
         WHERE CLE.[Document No_] = No_) 
        WHEN 0 THEN 'NO' 
        ELSE 'YES' 
    END AS Comments, **/
    
    --CLE.[Due Date], 
    --BTC.[Territory Code], 
    --BTC.[Collection Method], 
    --BTC.[Payment Terms Code], 
    --BTC.Rating,

    -- Aging Buckets
    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') < 0) AS [Not Due],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') BETWEEN 0 AND 30) AS [0-30 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') BETWEEN 31 AND 60) AS [31-60 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') BETWEEN 61 AND 90) AS [61-90 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') BETWEEN 91 AND 120) AS [91-120 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') BETWEEN 121 AND 180) AS [121-180 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') BETWEEN 181 AND 365) AS [181-365 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-04-30') > 365) AS [>365 Days],

    -- Snapshot Date
    '2025-04-30' AS AgeAsOf

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= '2025-04-30'
    AND BTC.[Customer Posting Group] = 'TRADE'
   ;

go



--
--open
SELECT * FROM  [Production$Cust_ Ledger Entry] AS CLE  WHERE CLE.[Entry No_] = '108714903'

--closed
SELECT * FROM  [Production$Cust_ Ledger Entry] AS CLE  WHERE CLE.[Entry No_] = '106682976' -- and CLE.[Entry No_] = '108714903'
--
SELECT  * FROM [Production$Detailed Cust_ Ledg_ Entry]
where [Cust_ Ledger Entry No_] = '106682976'
--[Document No_] = 'S2924063'


---6
GO
CREATE VIEW dbo.vw_Customer_Ledger_Snapshot_20250519 AS
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance, 

    

    -- Aging Buckets
    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-05-14') < 0) AS [Not Due],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-05-14') BETWEEN 0 AND 30) AS [0-30 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-05-14') BETWEEN 31 AND 60) AS [31-60 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-05-14') BETWEEN 61 AND 90) AS [61-90 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-05-14') BETWEEN 91 AND 120) AS [91-120 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-05-14') BETWEEN 121 AND 180) AS [121-180 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-05-14') BETWEEN 181 AND 365) AS [181-365 Days],

    (SELECT SUM(Amount)
     FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]
       AND DATEDIFF(DAY, CLE.[Due Date], '2025-05-14') > 365) AS [>365 Days],

    -- Snapshot Date
    '2025-05-14' AS AgeAsOf

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= '2025-05-14'
    AND BTC.[Customer Posting Group] = 'TRADE';

go

--
WITH TOTALBAL AS (SELECT (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance
FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= '2025-04-30'
    AND BTC.[Customer Posting Group] = 'TRADE' 
    --and CLE.[Open] in ('1','0')
    )
    SELECT SUM(Balance) as totalbal from TOTALBAL
--
------------------------------------------xxxxxxxxxxxxxxxxxxxxxxxxxxxx END xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx----------------------------------------------

-- Open AR with PTC ssrs

SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    STC.Name AS selltoCustomerName,
    STC.[Latitude],
    STC.[Longitude], 
    BTC.[Bill-to Customer No_],
       BTC.Name as billtocustomername, 
       STC.[Blocked],
       case when STC.[Blocked] in ( '0','') then 'Active'
            --when STC.[Blocked] in ( '1','2','3')
            else 'Blocked'
            end as [Blocked Status],
       STC.[Blocked Reason],
    CASE CLE.[Document Type] 
        WHEN 0 THEN 'Transfer' 
        WHEN 1 THEN 'Payment' 
        WHEN 2 THEN 'Invoice' 
        WHEN 3 THEN 'Credit Memo' 
        WHEN 4 THEN 'Finance Charge Memo' 
        WHEN 5 THEN 'Reminder' 
        WHEN 6 THEN 'Refund' 
        ELSE '' 
    END AS Cust__Ledger_EntryDocumentType, 
    CLE.[Document No_] AS Cust__Ledger_EntryDocumentNo_, 
    CLE.Description AS Cust__Ledger_EntryDescription, 
    CLE.[Posting Date] AS Cust__Ledger_EntryPostingDate, 
    CLE.[Entry No_] AS Cust__Ledger_EntryEntryNo_, 
    CLE.[Global Dimension 1 Code] AS CSC,
    CASE CLE.[ELC Doc_ Type] 
        WHEN 0 THEN ' ' 
        WHEN 1 THEN 'Rental Contract' 
        WHEN 2 THEN 'Work Order' 
        WHEN 3 THEN 'Equipment Configurator' 
        WHEN 4 THEN 'Purchase Configurator' 
        WHEN 5 THEN 'Parts' 
        WHEN 6 THEN 'Maintenance Contract' 
        WHEN 7 THEN 'Project' 
        WHEN 8 THEN 'Cons. Order' 
        WHEN 9 THEN 'Financing' 
        WHEN 10 THEN 'Item Contract' 
        ELSE '' 
    END AS Cust__Ledger_EntryELCDoc_Type, 
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Cust__Ledger_EntryRemainingAmount, 
    
    DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) AS Age, 
    
    BTC.[Customer Posting Group], 
    BTC.[Responsibility Center],
    CASE 
    WHEN CLE.[Global Dimension 1 Code] = 0 THEN 'NA'
    WHEN CLE.[Global Dimension 1 Code] = 1 THEN 'Louisville'
    WHEN CLE.[Global Dimension 1 Code] = 2 THEN 'Columbus (NPDI)'
    WHEN CLE.[Global Dimension 1 Code] = 3 THEN 'Indianapolis'
    WHEN CLE.[Global Dimension 1 Code] = 4 THEN 'Dayton'
    WHEN CLE.[Global Dimension 1 Code] = 5 THEN 'Lexington'
    WHEN CLE.[Global Dimension 1 Code] = 6 THEN 'Cincinnati'
    WHEN CLE.[Global Dimension 1 Code] = 7 THEN 'Evansville'
    WHEN CLE.[Global Dimension 1 Code] = 8 THEN 'West Virginia'
    WHEN CLE.[Global Dimension 1 Code] = 9 THEN 'Erlanger'
    WHEN CLE.[Global Dimension 1 Code] = 10 THEN 'Warehouse Solutions'
    WHEN CLE.[Global Dimension 1 Code] = 11 THEN 'Tire Central'
    WHEN CLE.[Global Dimension 1 Code] = 14 THEN 'TMMK'
    WHEN CLE.[Global Dimension 1 Code] = 15 THEN 'TMMWV'
    WHEN CLE.[Global Dimension 1 Code] = 20 THEN 'Specialty Products'
    WHEN CLE.[Global Dimension 1 Code] = 21 THEN 'Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 31 THEN 'Cleveland'
    WHEN CLE.[Global Dimension 1 Code] = 32 THEN 'Toledo'
    WHEN CLE.[Global Dimension 1 Code] = 33 THEN 'Columbus OH'
    WHEN CLE.[Global Dimension 1 Code] = 39 THEN 'TMH Corporate'
    WHEN CLE.[Global Dimension 1 Code] = 40 THEN 'TRANSIT'
    ELSE 'Unknown'
END AS CSC_Name, 
    CLE.[Sell-to Customer No_], 
    CLE.[Global Dimension 2 Code] as ProfitCenterNo,
 
    RCH.[Contract Type], 
    STC.[Payment Method Code], 
    CLE.[Dispute Code], 
    CLE.[External Document No_], 
    CLE.[Salesperson Code], 
    STC.[External Document No_ Required] AS [PO Req], 
    RCH.[Document Type], 
    
    CASE 
        (SELECT COUNT(No_) 
         FROM [Production$Comment Line] 
         WHERE CLE.[Document No_] = No_) 
        WHEN 0 THEN 'NO' 
        ELSE 'YES' 
    END AS Comments, 
    
    CLE.[Due Date], 
    BTC.[Territory Code], 
    BTC.[Collection Method], 
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance, 
    
    -- Updated Aging Buckets
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) < 0) AS [Not Due], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 0 AND 30) AS [0-30 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 31 AND 60) AS [31-60 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 61 AND 90) AS [61-90 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 91 AND 120) AS [91-120 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 121 AND 180) AS [121-180 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 181 AND 330) AS [181-330 Days], 

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 331 AND 365) AS [331-365 Days], 

    -- New Aging Windows for 365+ Days

       (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) > 365) AS [365+ Days],  

    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 366 AND 730) AS [1-2 Years], 

    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 731 AND 1095) AS [2-3 Years], 

    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 1096 AND 1460) AS [3-4 Years], 

      (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry]
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) > 1460) AS [4+ Years], 

    CONVERT(Date, DATEADD(DAY, -1, { fn NOW() })) AS AgeAsOf, 
    BTC.[Payment Terms Code], 
    BTC.Rating

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= CONVERT(Date, DATEADD(DAY, -1, { fn NOW() })) 
    AND BTC.[Customer Posting Group] = 'TRADE' 
    AND CLE.[Customer No_] = ''
--
select top 100 * FROM [Production$Cust_ Ledger Entry]

EXEC sp_help '[Production$Cust_ Ledger Entry]'

--

--ROLL RATE ANALYSIS


WITH MonthSeries AS (
    SELECT CAST('2025-01-31' AS DATE) AS MonthEnd
    UNION ALL
    SELECT DATEADD(MONTH, 1, MonthEnd)
    FROM MonthSeries
    WHERE MonthEnd < EOMONTH(GETDATE())
),

 LedgerSnapshots AS (
    SELECT 
        E.[Customer No_] AS CustomerNo,
        M.MonthEnd,
        DATEDIFF(DAY, E.[Due Date], M.MonthEnd) AS Age,
        SUM(D.Amount) AS Balance
    FROM MonthSeries M
    JOIN [Production$Cust_ Ledger Entry] E 
        ON E.[Posting Date] <= M.MonthEnd
    JOIN [Production$Detailed Cust_ Ledg_ Entry] D
        ON E.[Entry No_] = D.[Cust_ Ledger Entry No_]
    WHERE D.Amount <> 0
    GROUP BY E.[Customer No_], M.MonthEnd, E.[Due Date]
)

, BucketedSnapshots AS (
    SELECT *,
        CASE 
            WHEN Age < 0 THEN 'Not Due'
            WHEN Age BETWEEN 0 AND 29 THEN '1-30 Days'
            WHEN Age BETWEEN 30 AND 59 THEN '31-60 Days'
            WHEN Age BETWEEN 60 AND 89 THEN '61-90 Days'
            WHEN Age BETWEEN 90 AND 119 THEN '91-120 Days'
            WHEN Age BETWEEN 121 AND 180 THEN '121-180 Days'
            WHEN Age BETWEEN 181 AND 330 THEN '181-330 Days'
            WHEN Age BETWEEN  331 AND 365 THEN '331-365 Days'
            WHEN Age >= 366 THEN '365+ Days'
        END AS AgingBucket
    FROM LedgerSnapshots
)
, Transitions AS (
    SELECT 
        curr.CustomerNo,
        curr.MonthEnd AS CurrentMonth,
        next.MonthEnd AS NextMonth,
        curr.AgingBucket AS CurrentBucket,
        next.AgingBucket AS NextBucket,
        curr.Balance AS CurrentBalance,
        next.Balance AS NextBalance
    FROM BucketedSnapshots curr
    JOIN BucketedSnapshots next
        ON curr.CustomerNo = next.CustomerNo
        AND next.MonthEnd = DATEADD(MONTH, 1, curr.MonthEnd)
)

SELECT 
    CurrentMonth,
    CurrentBucket,
    NextBucket,
    COUNT(DISTINCT CustomerNo) AS CustomerCount,
    SUM(CurrentBalance) AS CurrentBucketBalance,
    SUM(NextBalance) AS NextBucketBalance,
    ROUND(
        100.0 * COUNT(DISTINCT CustomerNo) /
        NULLIF(
            (SELECT COUNT(DISTINCT CustomerNo) 
             FROM Transitions ref 
             WHERE ref.CurrentMonth = Transitions.CurrentMonth 
             AND ref.CurrentBucket = Transitions.CurrentBucket), 0
        ), 2
    ) AS RollRatePercent
FROM Transitions
GROUP BY CurrentMonth, CurrentBucket, NextBucket
ORDER BY CurrentMonth, CurrentBucket, NextBucket
OPTION (MAXRECURSION 1000)



--

select min([Posting Date]) as mindate from [Production$Cust_ Ledger Entry]
--where [Posting Date]


--
