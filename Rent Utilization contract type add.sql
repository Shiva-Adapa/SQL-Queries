SELECT TOP (1000) [timestamp]
      ,[No_]
      ,[Sell-to Customer No_]
      ,[Bill-to Customer No_]
      ,[Bill-to Name]
      ,[Bill-to Name 2]
      ,[Bill-to Address]
      ,[Bill-to Address 2]
      ,[Bill-to City]
      ,[Bill-to Contact]
      ,[Your Reference]
      ,[Ship-to Code]
      ,[Ship-to Name]
      ,[Ship-to Name 2]
      ,[Ship-to Address]
      ,[Ship-to Address 2]
      ,[Ship-to City]
      ,[Ship-to Contact]
      ,[Order Date]
      ,[Posting Date]
      ,[Shipment Date]
      ,[Posting Description]
      ,[Payment Terms Code]
      ,[Due Date]
      ,[Payment Discount %]
      ,[Pmt_ Discount Date]
      ,[Shipment Method Code]
      ,[Location Code]
      ,[Shortcut Dimension 1 Code]
      ,[Shortcut Dimension 2 Code]
      ,[Customer Posting Group]
      ,[Currency Code]
      ,[Currency Factor]
      ,[Customer Price Group]
      ,[Prices Including VAT]
      ,[Invoice Disc_ Code]
      ,[Customer Disc_ Group]
      ,[Language Code]
      ,[Salesperson Code]
      ,[Order No_]
      ,[No_ Printed]
      ,[On Hold]
      ,[Applies-to Doc_ Type]
      ,[Applies-to Doc_ No_]
      ,[Bal_ Account No_]
      ,[Job No_]
      ,[VAT Registration No_]
      ,[Reason Code]
      ,[Gen_ Bus_ Posting Group]
      ,[EU 3-Party Trade]
      ,[Transaction Type]
      ,[Transport Method]
      ,[VAT Country Code]
      ,[Sell-to Customer Name]
      ,[Sell-to Customer Name 2]
      ,[Sell-to Address]
      ,[Sell-to Address 2]
      ,[Sell-to City]
      ,[Sell-to Contact]
      ,[Bill-to Post Code]
      ,[Bill-to County]
      ,[Bill-to Country Code]
      ,[Sell-to Post Code]
      ,[Sell-to County]
      ,[Sell-to Country Code]
      ,[Ship-to Post Code]
      ,[Ship-to County]
      ,[Ship-to Country Code]
      ,[Bal_ Account Type]
      ,[Exit Point]
      ,[Correction]
      ,[Document Date]
      ,[External Document No_]
      ,[Area]
      ,[Transaction Specification]
      ,[Payment Method Code]
      ,[Shipping Agent Code]
      ,[Package Tracking No_]
      ,[Pre-Assigned No_ Series]
      ,[No_ Series]
      ,[Order No_ Series]
      ,[Pre-Assigned No_]
      ,[User ID]
      ,[Source Code]
      ,[Tax Area Code]
      ,[Tax Liable]
      ,[VAT Bus_ Posting Group]
      ,[VAT Base Discount %]
      ,[Campaign No_]
      ,[Sell-to Contact No_]
      ,[Bill-to Contact No_]
      ,[Responsibility Center]
      ,[Service Mgt_ Document]
      ,[Allow Line Disc_]
      ,[Get Shipment Used]
      ,[Ship-to UPS Zone]
      ,[Tax Exemption No_]
      ,[Consolidated Invoice]
      ,[Transaction Mode]
      ,[Bank Account]
      ,[ELC Doc_ Type]
      ,[ELC Document No_]
      ,[Credit Approval No_]
      ,[Line Description Amount]
      ,[Line Description]
      ,[Financing No_]
      ,[Project No_]
      ,[Project Task]
      ,[Project Task Line No_]
      ,[Document User ID]
      ,[Creation Datetime]
      ,[Modified by]
      ,[Modification Datetime]
      ,[PO Required]
      ,[Ship or Pickup Sales]
      ,[Credit reason]
      ,[Credit User ID]
      ,[Credit datetime]
      ,[Credit invoice No_]
      ,[Preview User ID]
      ,[Credit Type]
      ,[Date Sent]
      ,[Time Sent]
      ,[BizTalk Sales Invoice]
      ,[Customer Order No_]
      ,[BizTalk Document Sent]
      ,[Item No_]
      ,[Equipment Object]
      ,[Object Serial No_]
      ,[Transaction Mode Code]
      ,[Bank Account Code]
      ,[Document Output Code]
      ,[Document Output Count]
      ,[CRM Case Code]
      ,[CRM Action Parameter]
      ,[Customer Price Group Parts]
      ,[Customer Price Group Resources]
      ,[Customer Price Group Charges]
      ,[Agent]
      ,[Qualitiy Manager]
      ,[Salesperson Code 2]
      ,[Belong to Main Object]
      ,[Prepayment No_ Series]
      ,[Prepayment Invoice]
      ,[Prepayment Order No_]
  FROM [Copyofproduction ].[dbo].[Production$Sales Invoice Header] 
  left JOIN
                  [Production$Rental Contract Header] ON [Production$Sales Invoice Header].No_ =  [Production$Rental Contract Header].[No_] 
  where No_ = 'RO-000190'



  select DISTINCT([Contract Type]) from [Production$Sales Invoice Line]

  where [Document No_] like 'R%'

------------rental revenue--

  SELECT 
                GL.[Document No_] AS [GL Document Number],
                GL.Amount,
                GL.[Equipment Object] AS [Equipment Number],
                GL.[Posting Date],
                SIH.[Responsibility Center] AS [CSC Code],
                RCH.No_ AS [R_Contract No_],
                RCH.[Contract Type],
                SIH.[ELC Doc_ Type] AS [DocType Code],
                EO.[Default Rental Return Location],
                EO.[Equipment Category],
                EO.[Equipment Group],
                EO.[Equipment Model],
                SIH.[Ship-to Address],
                SIH.[Ship-to City],
                SIH.[Ship-to County],
                SIH.[Ship-to Post Code],
                GL.[G_L Account No_]
--test validation dec 2025 revenue---rent utilization report
                select GL.[G_L Account No_],GL.[Posting Date],sum(GL.Amount) as Amount,
                case when GL.[G_L Account No_] = '45005' then 'ST Rent Revenue' and GL.[G_L Account No_] ='45010' then 'LT Rent Revenue'
             FROM [Production$G_L Entry] AS GL
             LEFT JOIN [Production$Sales Invoice Header] AS SIH ON SIH.No_ = GL.[Document No_]
             --LEFT JOIN [Production$Rental Contract Header] AS RCH   ---- this join is causing the error.
    --ON GL.[Document No_] LIKE RCH.[No_] + '%'

             LEFT JOIN [Production$Equipment Object] AS EO ON GL.[Equipment Object] = EO.No_
             WHERE 
                GL.[G_L Account No_] in ( '45005', '45010','45070','45080','45030','45020','45015','45075','45007','46057','55070','55080','55076','55086')
                --AND GL.[G_L Account No_] <= '45099' 
                and GL.[Posting Date] between '12/01/2025' and '12/31/2025'
                --and RCH.[Contract Type] NOT in ('4WPRLFTFIN','DOLC','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN')
                --and GL.[Document No_] LIKE 'RO-004374%'
                group by GL.[G_L Account No_],GL.[Posting Date]
  ----test GL Budget

    SELECT [G_L Account No_],[Date], sum([Amount]) AS Budget
    FROM [Copyofproduction].[dbo].[Production$G_L Budget Entry]
    WHERE [Budget Name] = 'CURRENT' 
      and  [Date] > '2025-01-01' 
      and [G_L Account No_] in ( '45005', '45010','45070','45080','45030','45020','45015','45075','45007','46057')
    GROUP BY [G_L Account No_],[Date]

  -------  
--new GL Entry updaetd 

SELECT
    GL.[G_L Account No_]                                   AS GL_Account_No,
    GL.[Posting Date],
    -SUM(GL.Amount)                                         AS Amount,

    CASE
        WHEN GL.[G_L Account No_] IN ('45005','45010') THEN 'ST/LT Rent Revenue'
        WHEN GL.[G_L Account No_] =  '55070'               THEN 'ST/LT COGS Parts'
        WHEN GL.[G_L Account No_] =  '55080'               THEN 'ST/LT COGS Service'
        WHEN GL.[G_L Account No_] =  '45030'               THEN 'Sublet Rental Revenue'
        WHEN GL.[G_L Account No_] =  '55030'               THEN 'COGS Sublet'
        WHEN GL.[G_L Account No_] =  '45080'               THEN 'ST/LT Discounts'
        WHEN GL.[G_L Account No_] =  '45015'               THEN 'Flex Revenue'
        WHEN GL.[G_L Account No_] =  '45075'               THEN 'Flex Discount'
        WHEN GL.[G_L Account No_] =  '55076'               THEN 'Flex COGS Parts'
        WHEN GL.[G_L Account No_] =  '55086'               THEN 'Flex COGS Service'
        ELSE 'Other/Unmapped'
    END                                                    AS GL_Flag

FROM [Production$G_L Entry] AS GL
LEFT JOIN [Production$Sales Invoice Header] AS SIH
    ON SIH.No_ = GL.[Document No_]
LEFT JOIN [Production$Equipment Object] AS EO
    ON GL.[Equipment Object] = EO.No_

WHERE GL.[G_L Account No_] IN
(
    '45005','45010','45070','45080','45030','45020','45015','45075','45007','46057',
    '55070','55080','55076','55086','55030' -- added 55030 since you referenced it
)
AND GL.[Posting Date] >= '2025-12-01'
AND GL.[Posting Date] <  '2026-01-01'

GROUP BY
    GL.[G_L Account No_],
    GL.[Posting Date],
    CASE
        WHEN GL.[G_L Account No_] IN ('45005','45010') THEN 'ST/LT Rent Revenue'
        WHEN GL.[G_L Account No_] =  '55070'               THEN 'ST/LT COGS Parts'
        WHEN GL.[G_L Account No_] =  '55080'               THEN 'ST/LT COGS Service'
        WHEN GL.[G_L Account No_] =  '45030'               THEN 'Sublet Rental Revenue'
        WHEN GL.[G_L Account No_] =  '55030'               THEN 'COGS Sublet'
        WHEN GL.[G_L Account No_] =  '45080'               THEN 'ST/LT Discounts'
        WHEN GL.[G_L Account No_] =  '45015'               THEN 'Flex Revenue'
        WHEN GL.[G_L Account No_] =  '45075'               THEN 'Flex Discount'
        WHEN GL.[G_L Account No_] =  '55076'               THEN 'Flex COGS Parts'
        WHEN GL.[G_L Account No_] =  '55086'               THEN 'Flex COGS Service'
        ELSE 'Other/Unmapped'
    END
ORDER BY
    GL.[Posting Date],
    GL.[G_L Account No_];

----- Rental Maintenace ratio summary 
WITH GLBase AS
(
    SELECT
        DATEFROMPARTS(YEAR(GL.[Posting Date]), MONTH(GL.[Posting Date]), 1) AS MonthStart,
        GL.[G_L Account No_]                                                AS GL_Account_No,
        GL.Amount
    FROM [Production$G_L Entry] GL
    WHERE GL.[G_L Account No_] IN
    (
        '45005','45010','45080',
        '55070','55080',
        '45015','45075',
        '55076','55086'
    )
    AND GL.[Posting Date] >= '2024-01-01'
    --AND GL.[Posting Date] <  '2026-01-01'
),
Monthly AS
(
    SELECT
        MonthStart,

        -- ST/LT
        -SUM(CASE WHEN GL_Account_No IN ('45005','45010','45080') THEN Amount ELSE 0 END) AS STLT_Net_Revenue,
        SUM(CASE WHEN GL_Account_No IN ('55070','55080')         THEN Amount ELSE 0 END) AS STLT_Maintenance,

        -- Flex
        -SUM(CASE WHEN GL_Account_No IN ('45015','45075')         THEN Amount ELSE 0 END) AS Flex_Net_Revenue,
        SUM(CASE WHEN GL_Account_No IN ('55076','55086')         THEN Amount ELSE 0 END) AS Flex_Maintenance

    FROM GLBase
    GROUP BY MonthStart
)
SELECT
    MonthStart,

    STLT_Net_Revenue,
    STLT_Maintenance,
    CAST(STLT_Maintenance AS decimal(18,6)) / NULLIF(CAST(STLT_Net_Revenue AS decimal(18,6)), 0) AS STLT_Maintenance_Ratio,

    Flex_Net_Revenue,
    Flex_Maintenance,
    CAST(Flex_Maintenance AS decimal(18,6)) / NULLIF(CAST(Flex_Net_Revenue AS decimal(18,6)), 0) AS Flex_Maintenance_Ratio,

    -- Combined ST/LT + Flex
    (STLT_Net_Revenue + Flex_Net_Revenue)            AS Combined_Net_Revenue,
    (STLT_Maintenance + Flex_Maintenance)            AS Combined_Maintenance,
    CAST((STLT_Maintenance + Flex_Maintenance) AS decimal(18,6))
        / NULLIF(CAST((STLT_Net_Revenue + Flex_Net_Revenue) AS decimal(18,6)), 0) AS Combined_Maintenance_Ratio

FROM Monthly
ORDER BY MonthStart;


---rental maintenance budget summary updaetd 
WITH BudgetBase AS
(
    SELECT
        DATEFROMPARTS(YEAR(B.[Date]), MONTH(B.[Date]), 1) AS MonthStart,
        B.[G_L Account No_]                               AS GL_Account_No,
        B.[Amount]
    FROM [Copyofproduction].[dbo].[Production$G_L Budget Entry] B
    WHERE
        B.[Budget Name] = 'CURRENT'
        AND B.[Date] >= '2024-01-01'
        --AND B.[Date] <  '2026-01-01'
        AND B.[G_L Account No_] IN
        (
            '45005','45010','45080',
            '55070','55080',
            '45015','45075',
            '55076','55086'
        )
),
MonthlyBudget AS
(
    SELECT
        MonthStart,

        -- ST/LT
        -SUM(CASE WHEN GL_Account_No IN ('45005','45010','45080') THEN Amount ELSE 0 END) AS STLT_Net_Revenue_Budget,
        SUM(CASE WHEN GL_Account_No IN ('55070','55080')         THEN Amount ELSE 0 END) AS STLT_Maintenance_Budget,

        -- Flex
        -SUM(CASE WHEN GL_Account_No IN ('45015','45075')         THEN Amount ELSE 0 END) AS Flex_Net_Revenue_Budget,
        SUM(CASE WHEN GL_Account_No IN ('55076','55086')         THEN Amount ELSE 0 END) AS Flex_Maintenance_Budget

    FROM BudgetBase
    GROUP BY MonthStart
)
SELECT
    MonthStart,

    STLT_Net_Revenue_Budget,
    STLT_Maintenance_Budget,
    CAST(STLT_Maintenance_Budget AS decimal(18,6))
        / NULLIF(CAST(STLT_Net_Revenue_Budget AS decimal(18,6)), 0) AS STLT_Maintenance_Ratio_Budget,

    Flex_Net_Revenue_Budget,
    Flex_Maintenance_Budget,
    CAST(Flex_Maintenance_Budget AS decimal(18,6))
        / NULLIF(CAST(Flex_Net_Revenue_Budget AS decimal(18,6)), 0) AS Flex_Maintenance_Ratio_Budget,

    -- Combined
    (STLT_Net_Revenue_Budget + Flex_Net_Revenue_Budget) AS Combined_Net_Revenue_Budget,
    (STLT_Maintenance_Budget + Flex_Maintenance_Budget) AS Combined_Maintenance_Budget,
    CAST((STLT_Maintenance_Budget + Flex_Maintenance_Budget) AS decimal(18,6))
        / NULLIF(CAST((STLT_Net_Revenue_Budget + Flex_Net_Revenue_Budget) AS decimal(18,6)), 0)
        AS Combined_Maintenance_Ratio_Budget

FROM MonthlyBudget
ORDER BY MonthStart;


-----

---

------Rental revenue types 
SELECT 
                GL.[Document No_] AS [GL Document Number],
                GL.Amount,
                GL.[Equipment Object] AS [Equipment Number],
                GL.[Posting Date],
                SIH.[Responsibility Center] AS [CSC Code],
                --RCH.No_ AS [R_Contract No_],
                --RCH.[Contract Type],
                SIH.[ELC Doc_ Type] AS [DocType Code],
                EO.[Default Rental Return Location],
                EO.[Equipment Category],
                EO.[Equipment Group],
                EO.[Equipment Model],
                SIH.[Ship-to Address],
                SIH.[Ship-to City],
                SIH.[Ship-to County],
                SIH.[Ship-to Post Code],
                GL.[G_L Account No_]

                
    select sum(GL.Amount)
             FROM [Production$G_L Entry] AS GL
             LEFT JOIN [Production$Sales Invoice Header] AS SIH ON SIH.No_ = GL.[Document No_]
            -- LEFT JOIN [Production$Rental Contract Header] AS RCH
    --ON GL.[Document No_] LIKE RCH.[No_] + '%'

             LEFT JOIN [Production$Equipment Object] AS EO ON GL.[Equipment Object] = EO.No_
             WHERE 
                GL.[G_L Account No_] in ( '45015' , '45075')
                and GL.[Posting Date] between '12/01/2025' and '12/31/2025'
                --AND GL.[G_L Account No_] <= '45099'
                --and RCH.[Contract Type] NOT in ('4WPRLFTFIN','DOLC','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN')
                --and GL.[Document No_] LIKE 'RO-004374%'


--------

--------------------------
  select *          FROM [Production$G_L Entry] AS GL 
  WHERE  GL.[G_L Account No_] >= '45000'
                AND GL.[G_L Account No_] <= '45099'
  AND GL.[Document No_] LIKE  'RO-036136%'


  ----
  Select No_, [Contract Type] from [Production$Rental Contract Header]
  where [Contract Type] in ('4WPRLFTFIN','DOLC','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN')



  ---- seasonality check 


  WITH BaseData AS (
    SELECT
        GL.Amount AS Revenue,
        GL.[Posting Date] AS PostingDate,
        RCH.[Contract Type] AS ContractType
    FROM [Production$G_L Entry] AS GL
    LEFT JOIN [Production$Sales Invoice Header] AS SIH 
        ON SIH.No_ = GL.[Document No_]
    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON GL.[Document No_] LIKE RCH.[No_] + '%'
    LEFT JOIN [Production$Equipment Object] AS EO 
        ON GL.[Equipment Object] = EO.No_
    WHERE 
        GL.[G_L Account No_] BETWEEN '45000' AND '45099'
        AND RCH.[Contract Type] NOT IN 
            ('4WPRLFTFIN','DOLC','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN')
            and GL.[Posting Date] >= '01/01/2020'
),

-- Step 2: Monthly Aggregation
MonthlyAgg AS (
    SELECT
        ContractType,
        YEAR(PostingDate) AS [Year],
        MONTH(PostingDate) AS [Month],
        SUM(Revenue) AS MonthlyRevenue
    FROM BaseData
    GROUP BY ContractType, YEAR(PostingDate), MONTH(PostingDate)
),

-- Step 3: Overall average revenue per Contract Type
ContractTypeAvg AS (
    SELECT 
        ContractType,
        AVG(MonthlyRevenue) AS AvgMonthlyRevenue_CT
    FROM MonthlyAgg
    GROUP BY ContractType
),

-- Step 4: Seasonality Index = Monthly Revenue / Contract Type Avg Revenue
Seasonality AS (
    SELECT
        M.ContractType,
        M.[Year],
        M.[Month],
        M.MonthlyRevenue,
        C.AvgMonthlyRevenue_CT,
        CAST(M.MonthlyRevenue / NULLIF(C.AvgMonthlyRevenue_CT, 0) AS DECIMAL(10,4)) 
            AS SeasonalityIndex
    FROM MonthlyAgg M
    INNER JOIN ContractTypeAvg C
        ON M.ContractType = C.ContractType
)

-- Final Output with Interpretation
SELECT
    ContractType,
    [Year],
    [Month],
    MonthlyRevenue,
    AvgMonthlyRevenue_CT,
    SeasonalityIndex,
    CASE 
        WHEN SeasonalityIndex > 1.20 THEN 'High Seasonality (Above Normal)'
        WHEN SeasonalityIndex < 0.80 THEN 'Low Seasonality (Below Normal)'
        ELSE 'Normal'
    END AS SeasonalityFlag
FROM Seasonality
ORDER BY ContractType, [Year], [Month];



-----ANOVA Test for seasonality check 

WITH BaseData AS (
    SELECT
        RCH.[Contract Type] AS ContractType,
        GL.Amount AS Revenue,
        GL.[Posting Date] AS PostingDate
    FROM [Production$G_L Entry] GL
    LEFT JOIN [Production$Sales Invoice Header] SIH 
        ON SIH.No_ = GL.[Document No_]
    LEFT JOIN [Production$Rental Contract Header] RCH
        ON GL.[Document No_] LIKE RCH.[No_] + '%'
    WHERE 
        GL.[G_L Account No_] BETWEEN '45000' AND '45099'
        AND RCH.[Contract Type] NOT IN 
            ('4WPRLFTFIN','DOLC','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN')
        AND GL.[Posting Date] >= DATEADD(YEAR, -5, GETDATE())
),

MonthlyAgg AS (
    SELECT
        ContractType,
        MONTH(PostingDate) AS MonthNum,
        SUM(Revenue) AS MonthlyRevenue
    FROM BaseData
    GROUP BY ContractType, MONTH(PostingDate)
),

OverallStats AS (
    SELECT
        ContractType,
        AVG(MonthlyRevenue) AS OverallMean
    FROM MonthlyAgg
    GROUP BY ContractType
),

ANOVA AS (
    SELECT
        M.ContractType,
        M.MonthNum,
        M.MonthlyRevenue,
        O.OverallMean,
        POWER(M.MonthlyRevenue - O.OverallMean, 2) AS SS_between
    FROM MonthlyAgg M
    INNER JOIN OverallStats O
        ON M.ContractType = O.ContractType
),

ANOVA_Final AS (
    SELECT
        ContractType,
        SUM(SS_between) AS SS_between_total,
        COUNT(*) AS k_months,
        SUM(POWER(MonthlyRevenue - OverallMean, 2)) AS SS_total
    FROM ANOVA
    GROUP BY ContractType
)

SELECT
    ContractType,
    SS_between_total,
    SS_total - SS_between_total AS SS_within,
    k_months,
    k_months - 1 AS df_between,
    (12 - k_months) AS df_within,

    -- Mean Squares (SAFE)
    SS_between_total / NULLIF(k_months - 1, 0) AS MS_between,
    (SS_total - SS_between_total) / NULLIF((12 - k_months), 0) AS MS_within,

    -- F-statistic (SAFE)
    CASE 
        WHEN NULLIF((SS_total - SS_between_total), 0) IS NULL 
            OR NULLIF((12 - k_months), 0) IS NULL 
            OR NULLIF(k_months - 1, 0) IS NULL
        THEN NULL
        ELSE 
            (SS_between_total / NULLIF(k_months - 1, 0)) /
            ((SS_total - SS_between_total) / NULLIF((12 - k_months), 0))
    END AS F_statistic,

    -- Seasonality Decision (SAFE)
    CASE 
        WHEN NULLIF((SS_total - SS_between_total), 0) IS NULL 
            OR NULLIF((12 - k_months), 0) IS NULL 
            OR NULLIF(k_months - 1, 0) IS NULL
            THEN 'Insufficient Data'
        WHEN 
            (
                (SS_between_total / NULLIF(k_months - 1, 0)) /
                ((SS_total - SS_between_total) / NULLIF((12 - k_months), 0))
            ) > 1.84
            THEN 'Seasonality Exists (Significant at α = 0.05)'
        ELSE 'No Significant Seasonality'
    END AS Seasonality_Result

FROM ANOVA_Final;



fever 