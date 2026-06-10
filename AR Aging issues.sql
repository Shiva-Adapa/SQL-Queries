--Open AR SSRS

SELECT 
    CLE.[Customer No_] AS Cust_Ledger_EntryCustomerNo,
    SellToCustomer.Name AS CustomerName, 
    
    -- Document Type Mapping
    CASE CLE.[Document Type] 
        WHEN 0 THEN 'Transfer' 
        WHEN 1 THEN 'Payment' 
        WHEN 2 THEN 'Invoice' 
        WHEN 3 THEN 'Credit Memo' 
        WHEN 4 THEN 'Finance Charge Memo' 
        WHEN 5 THEN 'Reminder' 
        WHEN 6 THEN 'Refund' 
        ELSE '' 
    END AS Cust_Ledger_EntryDocumentType, 
    
    CLE.[Document No_] AS Cust_Ledger_EntryDocumentNo,
    CLE.Description AS Cust_Ledger_EntryDescription,
    CLE.[Posting Date] AS Cust_Ledger_EntryPostingDate,
    CLE.[Entry No_] AS Cust_Ledger_EntryEntryNo,

    -- ELC Document Type Mapping
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
    END AS Cust_Ledger_EntryELCDoc_Type,

    -- Balance Calculations
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Cust_Ledger_EntryRemainingAmount,

    -- Age Calculation
    DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) AS Age,

    -- Other Customer & Contract Information
    BillToCustomer.[Customer Posting Group],
    CLE.[Responsibility Center],
    CLE.[Sell-to Customer No_],
    BillToCustomer.Name,
    RCH.[Contract Type],
    SellToCustomer.[Payment Method Code],
    CLE.[Dispute Code],
    CLE.[External Document No_],
    CLE.[Salesperson Code],
    SellToCustomer.[External Document No_ Required] AS [PO Req],
    RCH.[Document Type],
    
    -- Comments Check
    CASE 
        WHEN (SELECT COUNT(No_) 
              FROM [Production$Comment Line] 
              WHERE CLE.[Document No_] = No_) = 0 THEN 'NO' 
        ELSE 'YES' 
    END AS Comments,

    -- Additional Customer Data
    CLE.[Due Date],
    BillToCustomer.[Territory Code],
    BillToCustomer.[Collection Method],

    -- Balance Breakdown by Aging Buckets
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance,

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_] 
           AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) < 0) AS [Not Due],

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_] 
           AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 0 AND 29) AS [1-31 Days],

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_] 
           AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 30 AND 59) AS [32-61 Days],

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_] 
           AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 60 AND 89) AS [62-92 Days],

    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_] 
           AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) >= 90) AS [More than 92 Days],

    -- Report Date
    CONVERT(Date, DATEADD(DAY, -1, { fn NOW() })) AS AgeAsOf

FROM [Production$Cust_ Ledger Entry] CLE
LEFT JOIN [Production$Rental Contract Header] RCH 
    ON CLE.[ELC Document No_] = RCH.No_ 
    AND RCH.[Document Type] = 1
LEFT JOIN Production$Customer BillToCustomer 
    ON CLE.[Customer No_] = BillToCustomer.No_
LEFT JOIN Production$Salesperson_Purchaser SP 
    ON SP.Code = CLE.[Salesperson Code]
LEFT JOIN Production$Customer SellToCustomer 
    ON CLE.[Sell-to Customer No_] = SellToCustomer.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0
    AND CLE.[Posting Date] <= CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))
    AND BillToCustomer.[Customer Posting Group] = 'TRADE'
    AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) >= 0;


-- Open AR with PTC ssrs

SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    STC.Name AS CustomerName, 
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
    CLE.[Responsibility Center], 
    CLE.[Sell-to Customer No_], 
    BTC.Name, 
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
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) < 0) AS [Not Due], 
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 0 AND 29) AS [1-31 Days], 
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 30 AND 59) AS [32-61 Days], 
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) BETWEEN 60 AND 89) AS [62-92 Days], 
    
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) >= 90) AS [More than 92 Days], 
    
    CONVERT(Date, DATEADD(DAY, -1, { fn NOW() })) AS AgeAsOf, 
    BTC.[Payment Terms Code], 
    BTC.Rating

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Salesperson_Purchaser AS SPP 
    ON SPP.Code = CLE.[Salesperson Code] 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
    AND CLE.[Posting Date] <= CONVERT(Date, DATEADD(DAY, -1, { fn NOW() })) 
    AND BTC.[Customer Posting Group] = 'TRADE';

--- Open AR updated for AR Aging 

WITH Customer_AR AS (
    SELECT 
        CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_,
        SUM(DLE.Amount) AS AR_Balance
    FROM [Production$Cust_ Ledger Entry] AS CLE
    LEFT JOIN [Production$Detailed Cust_ Ledg_ Entry] AS DLE 
        ON CLE.[Entry No_] = DLE.[Cust_ Ledger Entry No_]
    WHERE CLE.[Posting Date] <= GETDATE()
    GROUP BY CLE.[Customer No_]
),
Total_AR AS (
    SELECT SUM(AR_Balance) AS Total_Balance FROM Customer_AR
)
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    STC.Name AS CustomerName, 
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
    AR.AR_Balance,
    (AR.AR_Balance / T.Total_Balance) * 100 AS Percentile_Share,  -- Percentile Share Calculation
    DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) AS Age, 
    BTC.[Customer Posting Group], 
    CLE.[Responsibility Center], 
    CLE.[Sell-to Customer No_], 
    BTC.Name, 
    STC.[Payment Method Code], 
    CLE.[Dispute Code], 
    CLE.[External Document No_], 
    CLE.[Salesperson Code], 
    STC.[External Document No_ Required] AS [PO Req], 
    CASE 
        (SELECT COUNT(No_) FROM [Production$Comment Line] WHERE CLE.[Document No_] = No_) 
        WHEN 0 THEN 'NO' ELSE 'YES' 
    END AS Comments, 
    CLE.[Due Date], 
    BTC.[Territory Code], 
    BTC.[Collection Method], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) < 0) AS [Not Due], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 0 AND 30) AS [0-30 Days], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 31 AND 60) AS [31-60 Days], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 61 AND 90) AS [61-90 Days], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 91 AND 120) AS [91-120 Days], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 121 AND 180) AS [121-180 Days], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 181 AND 330) AS [181-330 Days], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 331 AND 365) AS [331-365 Days], 
    (SELECT SUM(Amount) FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], GETDATE()) >= 366) AS [365+ Days], 
     SUM(
            CASE 
                WHEN DLE.[Entry Type] = 1 THEN DLE.[Amount (LCY)] 
                ELSE 0 
            END
        ) AS [Original Amount],
    GETDATE() AS AgeAsOf, 
    BTC.[Payment Terms Code], 
    BTC.Rating
FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN Production$Customer AS BTC ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC ON CLE.[Sell-to Customer No_] = STC.No_
LEFT JOIN Customer_AR AS AR ON CLE.[Customer No_] = AR.Cust__Ledger_EntryCustomerNo_
CROSS JOIN Total_AR AS T
WHERE 
    AR.AR_Balance <> 0 
    AND CLE.[Posting Date] <= GETDATE() 
    AND BTC.[Customer Posting Group] = 'TRADE';




--- PBI MWAR 
WITH Filtered_Cust_Ledger_Entry AS (
    SELECT 
        CLE.*
    FROM [Production$Cust_ Ledger Entry] AS CLE
    LEFT JOIN [Production$Customer] AS BillToCustomer 
        ON CLE.[Customer No_] = BillToCustomer.No_
    WHERE (
        CLE.[Closed at Date] BETWEEN CONVERT(Date, DATEADD(DAY, -366, GETDATE())) 
                                  AND CONVERT(Date, DATEADD(DAY, -1, GETDATE()))
        OR CLE.[Open] = 1
    ) 
    AND BillToCustomer.[Customer Posting Group] = 'TRADE'
),
D_Cust_Ledg_Summary AS (
    SELECT 
        DCLE.[Cust_ Ledger Entry No_] AS EntryNo,
        SUM(DCLE.Amount) AS Balance,
        SUM(
            CASE 
                WHEN DCLE.[Entry Type] = 1 THEN DCLE.[Amount (LCY)] 
                ELSE 0 
            END
        ) AS [Original Amount]
    FROM [Production$Detailed Cust_ Ledg_ Entry] AS DCLE
    INNER JOIN Filtered_Cust_Ledger_Entry AS CLE 
        ON DCLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]
    GROUP BY DCLE.[Cust_ Ledger Entry No_]
)
SELECT top 10 
    CLE.[Customer No_] AS [Bill-To Customer No_],
    CLE.[Sell-to Customer No_],
    CLE.[Document No_] AS Cust__Ledger_EntryDocumentNo_,
    CLE.Description AS Cust__Ledger_EntryDescription,
    CLE.[Posting Date] AS Cust__Ledger_EntryPostingDate,
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
    CLE.[Responsibility Center],
    CLE.[External Document No_],
    CLE.[Salesperson Code],
    CLE.[Due Date],
    CLE.[Closed at Date],
    CLE.[Open],
    CLE.[Global Dimension 2 Code],
    DCLS.Balance,
    DCLS.[Original Amount]
FROM Filtered_Cust_Ledger_Entry AS CLE
LEFT JOIN D_Cust_Ledg_Summary AS DCLS 
    ON DCLS.EntryNo = CLE.[Entry No_];

-- pbi MwAR AR aging windows 

WITH Filtered_Cust_Ledger_Entry AS (
    SELECT 
        CLE.*
    FROM [Production$Cust_ Ledger Entry] AS CLE
    LEFT JOIN [Production$Customer] AS BillToCustomer 
        ON CLE.[Customer No_] = BillToCustomer.No_
    WHERE (
        CLE.[Closed at Date] BETWEEN CONVERT(Date, DATEADD(DAY, -366, GETDATE())) 
                                  AND CONVERT(Date, DATEADD(DAY, -1, GETDATE()))
        OR CLE.[Open] = 1
    ) 
    AND BillToCustomer.[Customer Posting Group] = 'TRADE'
),
D_Cust_Ledg_Summary AS (
    SELECT 
        DCLE.[Cust_ Ledger Entry No_] AS EntryNo,
        SUM(DCLE.Amount) AS Balance,
        SUM(
            CASE 
                WHEN DCLE.[Entry Type] = 1 THEN DCLE.[Amount (LCY)] 
                ELSE 0 
            END
        ) AS [Original Amount],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 0 AND 30 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [0-30 Days],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 31 AND 60 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [31-60 Days],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 61 AND 90 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [61-90 Days],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 91 AND 120 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [91-120 Days],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 121 AND 180 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [121-180 Days],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 181 AND 330 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [181-330 Days],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 331 AND 365 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [331-365 Days],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 366 AND 730 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [1-2 Years],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 731 AND 1095 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [2-3 Years],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 1096 AND 1460 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [3-4 Years],
        SUM(
            CASE 
                WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) > 1460 THEN DCLE.Amount
                ELSE 0 
            END
        ) AS [4+ Years]
    FROM [Production$Detailed Cust_ Ledg_ Entry] AS DCLE
    INNER JOIN Filtered_Cust_Ledger_Entry AS CLE 
        ON DCLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]
    GROUP BY DCLE.[Cust_ Ledger Entry No_]
)
SELECT
    CLE.[Customer No_] AS [Bill-To Customer No_],
    CLE.[Sell-to Customer No_],
    CLE.[Document No_] AS Cust__Ledger_EntryDocumentNo_,
    CLE.Description AS Cust__Ledger_EntryDescription,
    CLE.[Posting Date] AS Cust__Ledger_EntryPostingDate,
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
    CLE.[Responsibility Center],
    CLE.[External Document No_],
    CLE.[Salesperson Code],
    CLE.[Due Date],
    CLE.[Closed at Date],
    CASE CLE.[Open] WHEN 0 THEN 'Closed' else 'Open' end as [Status] ,
    CLE.[Global Dimension 2 Code],
    DCLS.Balance,
    DCLS.[Original Amount],
    DCLS.[0-30 Days],
    DCLS.[31-60 Days],
    DCLS.[61-90 Days],
    DCLS.[91-120 Days],
    DCLS.[121-180 Days],
    DCLS.[181-330 Days],
    DCLS.[331-365 Days],
    DCLS.[1-2 Years],
    DCLS.[2-3 Years],
    DCLS.[3-4 Years],
    DCLS.[4+ Years]
FROM Filtered_Cust_Ledger_Entry AS CLE
LEFT JOIN D_Cust_Ledg_Summary AS DCLS 
    ON DCLS.EntryNo = CLE.[Entry No_];




--testing Open AR SSRS 
SELECT 
SUM(Balance) as TotalBalance from (Select (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS Balance

from [Production$Cust_ Ledger Entry] CLE
LEFT JOIN [Production$Rental Contract Header] RCH 
    ON CLE.[ELC Document No_] = RCH.No_ 
    AND RCH.[Document Type] = 1
LEFT JOIN Production$Customer BillToCustomer 
    ON CLE.[Customer No_] = BillToCustomer.No_
LEFT JOIN Production$Salesperson_Purchaser SP 
    ON SP.Code = CLE.[Salesperson Code]
LEFT JOIN Production$Customer SellToCustomer 
    ON CLE.[Sell-to Customer No_] = SellToCustomer.No_

WHERE 
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] DLE 
     WHERE DLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0
    AND CLE.[Posting Date] <= CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))
    AND BillToCustomer.[Customer Posting Group] = 'TRADE') as subquery


--- tESTING Open AR PTC ssrs Tot Balance
SELECT 
    SUM(TOTBAL) AS TotalBalance
FROM (
    SELECT 
        (SELECT SUM(Amount) 
         FROM [Production$Detailed Cust_ Ledg_ Entry] 
         WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) AS TOTBAL
    FROM [Production$Cust_ Ledger Entry] AS CLE 
    LEFT JOIN [Production$Rental Contract Header] AS RCH 
        ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
    LEFT JOIN [Production$Customer] AS BTC 
        ON CLE.[Customer No_] = BTC.No_ 
    LEFT JOIN [Production$Salesperson_Purchaser] AS SPP 
        ON SPP.Code = CLE.[Salesperson Code] 
    LEFT JOIN [Production$Customer] AS STC 
        ON CLE.[Sell-to Customer No_] = STC.No_
    WHERE 
        (SELECT SUM(Amount) 
         FROM [Production$Detailed Cust_ Ledg_ Entry] 
         WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) <> 0 
        AND CLE.[Posting Date] <= CONVERT(Date, DATEADD(DAY, -1, GETDATE())) 
        AND BTC.[Customer Posting Group] = 'TRADE'
        --AND CLE.[Responsibility Center] = '33'
) AS SubQuery;



--testing AR Aging pbi Tot Balance of MWAR with out OH data

WITH Filtered_Cust_Ledger_Entry AS (
    SELECT 
        CLE.*
    FROM [Production$Cust_ Ledger Entry] AS CLE
    LEFT JOIN [Production$Customer] AS BillToCustomer 
        ON CLE.[Customer No_] = BillToCustomer.No_
    WHERE (
        CLE.[Closed at Date] BETWEEN CONVERT(Date, DATEADD(DAY, -366, GETDATE())) 
                                  AND CONVERT(Date, DATEADD(DAY, -1, GETDATE()))
        OR CLE.[Open] = 1
    ) 
    AND BillToCustomer.[Customer Posting Group] = 'TRADE'
),
D_Cust_Ledg_Summary AS (
    SELECT 
        DCLE.[Cust_ Ledger Entry No_] AS EntryNo,
        SUM(DCLE.Amount) AS Balance,
        SUM(
            CASE 
                WHEN DCLE.[Entry Type] = 1 THEN DCLE.[Amount (LCY)] 
                ELSE 0 
            END
        ) AS [Original Amount]
    FROM [Production$Detailed Cust_ Ledg_ Entry] AS DCLE
    INNER JOIN Filtered_Cust_Ledger_Entry AS CLE 
        ON DCLE.[Cust_ Ledger Entry No_] = CLE.[Entry No_]
    GROUP BY DCLE.[Cust_ Ledger Entry No_]
)
SELECT 
    SUM(DCLS.Balance) AS Total_Balance
FROM Filtered_Cust_Ledger_Entry AS CLE
LEFT JOIN D_Cust_Ledg_Summary AS DCLS 
    ON DCLS.EntryNo = CLE.[Entry No_]
--WHERE CLE.[Responsibility Center] = '33';



-- Customer Name grouped by for Lisa 

 --- grouped by customer name 

    WITH DetailedAmounts AS (
    SELECT 
        DCLE.[Cust_ Ledger Entry No_],
        SUM(DCLE.Amount) AS TotalAmount
    FROM [Production$Detailed Cust_ Ledg_ Entry] AS DCLE
    GROUP BY DCLE.[Cust_ Ledger Entry No_]
)
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    STC.Name AS CustomerName, 

    DA.TotalAmount AS Cust__Ledger_EntryRemainingAmount, 

    AVG(DATEDIFF(DAY, CLE.[Due Date], GETDATE())) AS AvgAge, 

    --BTC.[Customer Posting Group], 
    CLE.[Responsibility Center], 
    CLE.[Sell-to Customer No_], 
    CLE.[Global Dimension 2 Code] AS ProfitCenterNo, 
    --BTC.Name, 
    --RCH.[Contract Type], 
    --STC.[Payment Method Code], 
    --CLE.[Dispute Code], 
   -- CLE.[External Document No_], 
   -- CLE.[Salesperson Code], 
    --STC.[External Document No_ Required] AS [PO Req], 
   -- BTC.[Territory Code], 
   -- BTC.[Collection Method], 
   -- BTC.[Payment Terms Code], 
    BTC.Rating,

    -- AR Aging Windows Summarization
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) < 0 THEN DA.TotalAmount ELSE 0 END) AS [Not Due],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 0 AND 30 THEN DA.TotalAmount ELSE 0 END) AS [0-30 Days],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 31 AND 60 THEN DA.TotalAmount ELSE 0 END) AS [31-60 Days],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 61 AND 90 THEN DA.TotalAmount ELSE 0 END) AS [61-90 Days],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 91 AND 120 THEN DA.TotalAmount ELSE 0 END) AS [91-120 Days],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 121 AND 180 THEN DA.TotalAmount ELSE 0 END) AS [121-180 Days],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 181 AND 330 THEN DA.TotalAmount ELSE 0 END) AS [181-330 Days],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 331 AND 365 THEN DA.TotalAmount ELSE 0 END) AS [331-365 Days],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) > 365 THEN DA.TotalAmount ELSE 0 END) AS [365+ Days],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 366 AND 730 THEN DA.TotalAmount ELSE 0 END) AS [1-2 Years],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 731 AND 1095 THEN DA.TotalAmount ELSE 0 END) AS [2-3 Years],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) BETWEEN 1096 AND 1460 THEN DA.TotalAmount ELSE 0 END) AS [3-4 Years],
    SUM(CASE WHEN DATEDIFF(DAY, CLE.[Due Date], GETDATE()) > 1460 THEN DA.TotalAmount ELSE 0 END) AS [4+ Years]

FROM [Production$Cust_ Ledger Entry] AS CLE 
LEFT JOIN DetailedAmounts AS DA 
    ON CLE.[Entry No_] = DA.[Cust_ Ledger Entry No_]
LEFT JOIN [Production$Rental Contract Header] AS RCH 
    ON CLE.[ELC Document No_] = RCH.No_ AND RCH.[Document Type] = 1 
LEFT JOIN Production$Customer AS BTC 
    ON CLE.[Customer No_] = BTC.No_ 
LEFT JOIN Production$Customer AS STC 
    ON CLE.[Sell-to Customer No_] = STC.No_ 

WHERE 
    CLE.[Posting Date] <= CONVERT(Date, DATEADD(DAY, -1, GETDATE())) 
    AND BTC.[Customer Posting Group] = 'TRADE'



GROUP BY 
    CLE.[Customer No_], 
    STC.Name, 
    --BTC.[Customer Posting Group], 
    CLE.[Responsibility Center], 
    DA.TotalAmount,
    CLE.[Sell-to Customer No_], 
    CLE.[Global Dimension 2 Code], 
   -- BTC.Name, 
   -- RCH.[Contract Type], 
   -- STC.[Payment Method Code], 
    --CLE.[Dispute Code], 
    --CLE.[External Document No_], 
    --CLE.[Salesperson Code], 
    --STC.[External Document No_ Required], 
   -- BTC.[Territory Code], 
   -- BTC.[Collection Method], 
    --BTC.[Payment Terms Code], 
    BTC.Rating

    HAVING 
    DA.TotalAmount <> 0 


-- ADIENT customer  CHECK 
SELECT 
    CLE.[Customer No_] AS Cust__Ledger_EntryCustomerNo_, 
    STC.Name AS CustomerName, 
    BTC.[Bill-to Customer No_],
       BTC.Name, 
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
    AND  BTC.Name = 'Lubrizol' 
    --AND BTC.[Responsibility Center] = '33'
   /** AND ((SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_]) 
    <>
    -- Updated Aging Buckets
    (SELECT SUM(Amount) 
     FROM [Production$Detailed Cust_ Ledg_ Entry] 
     WHERE [Cust_ Ledger Entry No_] = CLE.[Entry No_] 
     AND DATEDIFF(DAY, CLE.[Due Date], CONVERT(Date, DATEADD(DAY, -1, { fn NOW() }))) < 0) )**/