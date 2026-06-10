SELECT TOP (1000) [timestamp]
      ,[Entry No_]
      ,[Item No_]
      ,[Posting Date]
      ,[Entry Type]
      ,[Source No_]
      ,[Document No_]
      ,[Description]
      ,[Location Code]
      ,[Quantity]
      ,[Remaining Quantity]
      ,[Invoiced Quantity]
      ,[Applies-to Entry]
      ,[Open]
      ,[Global Dimension 1 Code]
      ,[Global Dimension 2 Code]
      ,[Positive]
      ,[Source Type]
      ,[Drop Shipment]
      ,[Transaction Type]
      ,[Transport Method]
      ,[Country Code]
      ,[Entry_Exit Point]
      ,[Document Date]
      ,[External Document No_]
      ,[Area]
      ,[Transaction Specification]
      ,[No_ Series]
      ,[Prod_ Order No_]
      ,[Variant Code]
      ,[Qty_ per Unit of Measure]
      ,[Unit of Measure Code]
      ,[Derived from Blanket Order]
      ,[Cross-Reference No_]
      ,[Originally Ordered No_]
      ,[Originally Ordered Var_ Code]
      ,[Out-of-Stock Substitution]
      ,[Item Category Code]
      ,[Nonstock]
      ,[Purchasing Code]
      ,[Product Group Code]
      ,[Transfer Order No_]
      ,[Completely Invoiced]
      ,[Last Invoice Date]
      ,[Applied Entry to Adjust]
      ,[Correction]
      ,[Prod_ Order Line No_]
      ,[Prod_ Order Comp_ Line No_]
      ,[Service Order No_]
      ,[Serial No_]
      ,[Lot No_]
      ,[Warranty Date]
      ,[Expiration Date]
      ,[Return Reason Code]
      ,[Shipment Method Code]
      ,[Work Order No_]
      ,[Work Order Line No_]
      ,[Equipment Object]
      ,[Demand Location]
      ,[Claim No_]
      ,[Temporary Item]
  FROM [Copyofproduction ].[dbo].[Production$Item Ledger Entry]
  where
   --[Item No_] = 'NPAA021' and 
[Location Code] = '870'
  and [Open] = 1



  -----


  SELECT
    ILE.[Item No_],
    I.[Blocked],
    ILE.[Location Code],
    I.[Manufacturer Code],
    I.[Item Category Code] AS ICC_Code,
    IC.[Description] AS ICC_Description,

    MAX(ILE.[Posting Date]) AS [Last Posting Date],

    (
        SELECT MAX(ILE2.[Posting Date])
        FROM [Copyofproduction].[dbo].[Production$Item Ledger Entry] ILE2
        WHERE ILE2.[Item No_] = ILE.[Item No_]
          AND ILE2.[Entry Type] = 0
    ) AS Last_Purchase_Date,

    SUM(ILE.[Remaining Quantity]) AS Remaining_Quantity,
    ILE.[Demand Location],
    MAX(SKU.[Reorder Point]) AS ReorderPoint,

    CASE
        WHEN MAX(SKU.[Reorder Point]) > 0 THEN 'Yes'
        ELSE 'No'
    END AS Reorderflag,

    I.[Unit Cost],
    I.[Description],

    CASE
        WHEN LEN(ILE.[Location Code]) <= 2 THEN 'Central'
        ELSE 'Van'
    END AS LocationType,

    SUM(I.[Unit Cost] * ILE.[Remaining Quantity]) AS Inventory_Cost

FROM [Copyofproduction].[dbo].[Production$Item Ledger Entry] ILE
LEFT JOIN [Copyofproduction].[dbo].[Production$Item] I
    ON I.[No_] = ILE.[Item No_]
LEFT JOIN [Copyofproduction].[dbo].[Production$Item Category] IC
    ON I.[Item Category Code] = IC.[Code]
LEFT JOIN [Copyofproduction].[dbo].[Production$Stockkeeping Unit] SKU
    ON ILE.[Demand Location] = SKU.[Location Code]
   AND ILE.[Item No_] = SKU.[Item No_]
where ILE.[Item No_] = 'NPAA021'
GROUP BY
    ILE.[Item No_],
    I.[Blocked],
    ILE.[Location Code],
    ILE.[Demand Location],
    I.[Manufacturer Code],
    I.[Item Category Code],
    IC.[Description],
    I.[Unit Cost],
    I.[Description]

HAVING SUM(ILE.[Remaining Quantity]) > 0;





-----


WITH WOL_Agg AS (
    SELECT
     WOL.[Responsibility Center] AS [CSC],
      CASE 
    WHEN WOL.[Responsibility Center] = 0 THEN 'NA'
    WHEN WOL.[Responsibility Center] = 1 THEN 'Louisville'
    WHEN WOL.[Responsibility Center] = 2 THEN 'Columbus (NPDI)'
    WHEN WOL.[Responsibility Center] = 3 THEN 'Indianapolis'
    WHEN WOL.[Responsibility Center] = 4 THEN 'Dayton'
    WHEN WOL.[Responsibility Center] = 5 THEN 'Lexington'
    WHEN WOL.[Responsibility Center] = 6 THEN 'Cincinnati'
    WHEN WOL.[Responsibility Center] = 7 THEN 'Evansville'
    WHEN WOL.[Responsibility Center] = 8 THEN 'West Virginia'
    WHEN WOL.[Responsibility Center] = 9 THEN 'Erlanger'
    WHEN WOL.[Responsibility Center] = 10 THEN 'Warehouse Solutions'
    WHEN WOL.[Responsibility Center] = 11 THEN 'Tire Central'
    WHEN WOL.[Responsibility Center] = 14 THEN 'TMMK'
    WHEN WOL.[Responsibility Center] = 15 THEN 'TMMWV'
    WHEN WOL.[Responsibility Center] = 20 THEN 'Specialty Products'
    WHEN WOL.[Responsibility Center] = 21 THEN 'Corporate'
    WHEN WOL.[Responsibility Center] = 31 THEN 'Cleveland'
    WHEN WOL.[Responsibility Center] = 32 THEN 'Toledo'
    WHEN WOL.[Responsibility Center] = 33 THEN 'Columbus OH'
    WHEN WOL.[Responsibility Center] = 39 THEN 'TMH Corporate'
    WHEN WOL.[Responsibility Center] = 40 THEN 'TRANSIT'
    ELSE 'Unknown'
END AS CSC_Name,
        WOL.[Document No_],
     WOH.[Service Type],
     WOL.[Service Report],
     WOH.[Posting Date],
     WOL.[Work Type Code],
        --CAST(REPLACE(WOL.[Line No_], ',', '') AS DECIMAL(18,2)) [Line No_],
        WOL.[No_] AS [Resource Code],
        --WOH.[Posting Date],
        SUM(CAST(WOL.[Quantity Used] AS DECIMAL(10, 5))) AS [Total Quantity Used],
        SUM(CAST(WOL.[Quantity Invoiced] AS DECIMAL(10,5))) AS [Total Quantity Invoiced],
           WOL.[Unit Price] as [Unit Price],  -- bring this column with 
          sum(WOL.[Amount]) as [Amount]
    FROM 
        [Production$Work Order Header] AS WOH
        LEFT JOIN [Production$Work Order Line] AS WOL 
            ON WOL.[Document No_] = WOH.[No_]
       LEFT JOIN [Copyofproduction ].[dbo].[IntExtBilledService] CB
       ON CB.[Code] = WOH.[Service Type]
      
    WHERE 
       --WOH.[No_] = 'S3001475' AND
         WOL.[Type] = 2
        AND WOL.[Work Type Code] LIKE '%CUST%' 
        AND WOH.[Document Type] = 1
       and CB.[Type] = 'Customer Billed'
       AND WOH.[Posting Date] >= '2024-01-01'
    AND WOH.[Posting Date] <= CAST(GETDATE() AS DATE)
    AND WOL.[Quantity Used] <> 0

    GROUP BY 
        WOL.[No_],WOL.[Document No_],WOL.[Unit Price],
        --,WOL.[Quantity Invoiced]
        WOH.[Service Type],WOL.[Responsibility Center]
        ,WOL.[Service Report]
        , WOL.[Work Type Code]
        ,WOH.[Posting Date]
),

-- CTE for HL aggregation
HL_Agg AS (
    SELECT
        HL.[Resource No_] AS [Resource Code] , R.[Name] as Resource_Name, R.[Job Title],R.[Resource Group No_],
        --HL.[Work Order No_],
        HL.[Service Report],
        HL.[Work Order No_] ,
       -- SUM(HL.[Hours]) AS Hours,
        SUM(HL.[Billable Hours]) AS [.5 Rounding Hours],
         SUM(
        CASE 
            WHEN HL.[Activity Code] IN ('WORK', 'P2PTRAVEL') 
                THEN CEILING(HL.[Hours] * 4) / 4.0
            ELSE HL.[Hours]
        END
    ) AS [Rounded Hours to .25],

    -- Rounded to .5 ONLY for specific Activity Codes
    SUM(
        HL.[Billable Hours]
    ) AS [Rounded Hours to .5]
    FROM 
        [Production$Hour Line] AS HL 
         left join [Production$Resource] AS R
       ON HL.[Resource No_] = R.[No_]
    WHERE 
        HL.[Not Billable] = 0  
        --AND HL.[Work Type Code] LIKE '%CUST%' 
        --AND  HL.[Starting DateTime] >= '2025-02-12'
    AND HL.[Work Order No_] = 'S3222014'
    GROUP BY 
        HL.[Resource No_],HL.[Work Order No_],HL.[Service Report],R.[Name] , R.[Job Title],R.[Resource Group No_]
        --,HL.[Hours]
)


-- Final join
SELECT
    W.[CSC],
    W.CSC_Name,
    W.[Posting Date],
    W.[Service Type],
    W.[Document No_],
    W.[Resource Code], H.[Resource_Name],H.[Job Title],H.[Resource Group No_],
    W.[Service Report],
    W.[Work Type Code],
    --W.[Posting Date],
    --W.[Line No_],
    W.[Unit Price],
    W.[Total Quantity Used] [Total Tech Hrs Clocked],
    cast(H.[Rounded Hours to .25] as decimal (10,4)) [Expected Hrs when Rounded to .25],
    cast(H.[Rounded Hours to .5] as decimal (10,4)) [Expected Hrs when Rounded to .5],
     cast(H.[.5 Rounding Hours] as decimal (10,4)) [.5 Rounding Hours],

    CAST(W.[Total Quantity Invoiced] AS DECIMAL(10,4)) [Total Tech Hrs Invoiced],
    CAST((W.[Total Quantity Used] * W.[Unit Price]) AS DECIMAL(10,2)) AS [Expected Tech Amount before Rounding],
   CAST((H.[Rounded Hours to .25] * W.[Unit Price]) AS DECIMAL(10,2)) AS [Expected Tech Amount after Rounding to .25],
    CAST((H.[Rounded Hours to .5] * W.[Unit Price]) AS DECIMAL(10,2)) AS [Expected Tech Amount after Rounding to .5],
    CAST(W.[Amount] AS DECIMAL(10,2)) AS [WOL Actual Amount Invoiced],
    -- Flags
    CASE 
        WHEN W.[Total Quantity Invoiced] < W.[Total Quantity Used] THEN 'Yes' 
        ELSE 'No' 
    END AS [Invoiced less Hrs?],

    CASE 
        WHEN W.[Amount] < (W.[Total Quantity Used] * W.[Unit Price]) THEN 'Yes' 
        ELSE 'No' 
    END AS [Invoiced less Amount?],

    -- % Variance calculations
    
        CASE 
            WHEN (W.[Total Quantity Used] * W.[Unit Price]) = 0 THEN 0
            ELSE ((W.[Amount] - (W.[Total Quantity Used] * W.[Unit Price])) / (W.[Total Quantity Used] * W.[Unit Price])) 
        END
AS [% Variance Amount vs Expected (No Rounding)],

    
        CASE 
            WHEN (H.[Rounded Hours to .25] * W.[Unit Price]) = 0 THEN 0
            ELSE ((W.[Amount] - (H.[Rounded Hours to .25] * W.[Unit Price])) / (H.[Rounded Hours to .25] * W.[Unit Price])) 
        END
    AS [% Variance Amount vs Expected (Rounded to .25)],

  
        CASE 
            WHEN (H.[Rounded Hours to .5] * W.[Unit Price]) = 0 THEN 0
            ELSE ((W.[Amount] - (H.[Rounded Hours to .5] * W.[Unit Price])) / (H.[Rounded Hours to .5] * W.[Unit Price])) 
        END
    AS [% Variance Amount vs Expected (Rounded to .5)]

FROM 
    WOL_Agg W
    LEFT JOIN HL_Agg H 
        ON W.[Resource Code] = H.[Resource Code] 
        AND H.[Work Order No_] = W.[Document No_]
        and H.[Service Report] = W.[Service Report]
where H.[Work Order No_] = 'S3222014'




---

WITH base AS (
    SELECT
        b.[Global Dimension 1 Code] AS CSC,
        -- Month bucket (first day of month). For daily, use: CAST(b.[Posting Date] AS date)
        CAST(DATEADD(month, DATEDIFF(month, 0, b.[Posting Date]), 0) AS date) AS PostingDate,

        -- Keep both string and integer versions of the account
        CAST(b.[G_L Account No_] AS varchar(20)) AS GLAccountStr,
        CASE 
            WHEN CAST(b.[G_L Account No_] AS varchar(20)) NOT LIKE '%[^0-9]%' 
                 THEN CAST(b.[G_L Account No_] AS int)
            ELSE NULL
        END AS GLAccountInt,

        GLActual = CAST(-SUM(b.[Amount]) AS decimal(19,4))
    FROM [Production$G_L Entry] AS b
    WHERE b.[Global Dimension 2 Code] = '5'  
    --and b.[Posting Date] = '2026/03/31' and  b.[G_L Account No_] = 43030-- ProfitCenter: Service (CONSOLSERV)
    GROUP BY
        b.[Global Dimension 1 Code],
        DATEADD(month, DATEDIFF(month, 0, b.[Posting Date]), 0),
        b.[G_L Account No_]
),
sumper AS (
    SELECT
        PostingDate,
        CSC,

        -- 29: Total ALL Service Sales
        Sales29 =
            SUM(CASE
                    WHEN GLAccountInt like '4%'
                    THEN GLActual ELSE 0
                END),

        -- 30: Total ALL Service COGS
        COGS30 =
            SUM(CASE
                    WHEN GLAccountInt like '5%'
                    THEN GLActual ELSE 0
                END),

        -- Full Maintenance (6-account set)
        FM_Rev = SUM(CASE WHEN GLAccountInt IN (43010,43011) THEN GLActual ELSE 0 END),
        FM_All = SUM(CASE WHEN GLAccountInt IN (43010,43011,43008,40090,53010,53011) THEN GLActual ELSE 0 END),

        -- Total Operating Expense: accounts starting with 6, except 65200
        OpExp  = SUM(CASE WHEN (GLAccountInt BETWEEN 60000 AND 69999) AND GLAccountInt <> 65200
                          THEN GLActual ELSE 0 END)
    FROM base
    GROUP BY PostingDate, CSC
)
SELECT
    PostingDate,
    CSC,

    [Total ALL Service Sales] = Sales29,                           -- 29
    [Total ALL Service COGS]  = COGS30,                            -- 30
    [Total ALL Service GP]    = Sales29 + COGS30,                  -- 31
    [Total Service GP %]      = CASE WHEN Sales29 = 0 THEN NULL
                                     ELSE 1.0 * (Sales29 + COGS30) / Sales29 END,  -- R = 31/29

    [Full Maintenance GP]     = FM_All,
    [Full Maintenance Revenue]     = FM_Rev,
    [Full Maintenance GP %]   = CASE WHEN FM_Rev = 0 THEN NULL
                                     ELSE 1.0 * FM_All / FM_Rev END,

    [Total Operating Expense] = OpExp,
    [Total Service Expense %] = CASE WHEN Sales29 = 0 THEN NULL
                                     ELSE 1.0 * OpExp / Sales29 END,
     -- NEW: Operating Income = 31 | TE  (i.e., GP + OpEx)
    [Operating Income]        = (Sales29 + COGS30) + OpExp,

    -- NEW: Operating Income % = OI / 29
    [Operating Income %]      = CASE WHEN Sales29 = 0 THEN NULL
                                     ELSE 1.0 * ((Sales29 + COGS30) + OpExp) / Sales29 END
FROM sumper where PostingDate > '2026-01-01'
AND CSC = 1
ORDER BY PostingDate, CSC


---- Full Maintenance sql query 

SELECT
    -- Month bucket (first day of month)
    DATEFROMPARTS(YEAR(gl.[Posting Date]), MONTH(gl.[Posting Date]), 1) AS [Posting Date],
    gl.[Global Dimension 1 Code] AS [CSC],

    UPPER(
        CASE
            WHEN mch.[Contract Type] = 'GOLD' OR woh.[Service Type] LIKE '%GOLD%' THEN 'GOLD'
            WHEN mch.[Contract Type] = 'PLATINUM' OR woh.[Service Type] LIKE '%PLAT%' THEN 'PLATINUM'
            WHEN mch.[Contract Type] = 'SILVER' OR woh.[Service Type] LIKE '%SILVER%' THEN 'SILVER'
           
            ELSE 'OTHER'
        END
    ) AS [Contract Type],

    -- Revenue: 43030
    -SUM(CASE WHEN gl.[G_L Account No_] = '43030' THEN gl.[Amount] ELSE 0 END) AS [Revenue],

    -- Cost: 53020 + 53030
    SUM(CASE WHEN gl.[G_L Account No_] IN ('53020', '53030') THEN gl.[Amount] ELSE 0 END) AS [Cost],

    -- GP = Revenue - Cost
    -SUM(CASE WHEN gl.[G_L Account No_] = '43030' THEN gl.[Amount] ELSE 0 END)
    - SUM(CASE WHEN gl.[G_L Account No_] IN ('53020', '53030') THEN gl.[Amount] ELSE 0 END) AS [GP],

    -- GP% = GP / Revenue
    (
        -SUM(CASE WHEN gl.[G_L Account No_] = '43030' THEN gl.[Amount] ELSE 0 END)
        - SUM(CASE WHEN gl.[G_L Account No_] IN ('53020', '53030') THEN gl.[Amount] ELSE 0 END)
    ) / NULLIF(
        -SUM(CASE WHEN gl.[G_L Account No_] = '43030' THEN gl.[Amount] ELSE 0 END),
        0
    ) AS [GP_PCT]

FROM [Copyofproduction].[dbo].[Production$G_L Entry] gl
LEFT JOIN [Production$Maintenance Contract Header] mch
    ON mch.[No_] = gl.[ELC Document No_]
LEFT JOIN [Production$Work Order Header] woh
    ON woh.[No_] = gl.[Work Order No_]

WHERE
    gl.[Posting Date] >= '2026-01-01'
    -- AND gl.[Posting Date] < '2026-02-01'
    AND gl.[G_L Account No_] IN ('43030', '53030', '53020')
    AND gl.[Global Dimension 1 Code] = '1'

GROUP BY
    DATEFROMPARTS(YEAR(gl.[Posting Date]), MONTH(gl.[Posting Date]), 1),
    gl.[Global Dimension 1 Code],
    UPPER(
        CASE
            WHEN mch.[Contract Type] = 'GOLD' OR woh.[Service Type] LIKE '%GOLD%' THEN 'GOLD'
            WHEN mch.[Contract Type] = 'PLATINUM' OR woh.[Service Type] LIKE '%PLAT%' THEN 'PLATINUM'
            WHEN mch.[Contract Type] = 'SILVER' OR woh.[Service Type] LIKE '%SILVER%' THEN 'SILVER'
               
            ELSE 'OTHER'
        END
    )

ORDER BY
    [Posting Date],
    [Contract Type];





--- Full Maintenance 


---- Full Maintenance sql query 

SELECT
    -- Month bucket (first day of month)
   DATEFROMPARTS(YEAR(gl.[Posting Date]), MONTH(gl.[Posting Date]), 1) AS [Posting Date],
    gl.[Global Dimension 1 Code] AS [CSC],

 

    -- Revenue: 43030
    -SUM(CASE WHEN gl.[G_L Account No_] in ( '43030','43020') THEN gl.[Amount] ELSE 0 END) AS [Full Maintenance Revenue],

    -- Cost: 53020 + 53030
    SUM(CASE WHEN gl.[G_L Account No_] IN ('53020', '53030') THEN gl.[Amount] ELSE 0 END) AS [Full Maintenance Cost],

    -- GP = Revenue - Cost
    -SUM(CASE WHEN gl.[G_L Account No_]in ( '43030','43020') THEN gl.[Amount] ELSE 0 END)
    - SUM(CASE WHEN gl.[G_L Account No_] IN ('53020', '53030') THEN gl.[Amount] ELSE 0 END) AS [Full Maintenance GP],

    -- GP% = GP / Revenue
    (
        -SUM(CASE WHEN gl.[G_L Account No_] in ( '43030','43020') THEN gl.[Amount] ELSE 0 END)
        - SUM(CASE WHEN gl.[G_L Account No_] IN ('53020', '53030') THEN gl.[Amount] ELSE 0 END)
    ) / NULLIF(
        -SUM(CASE WHEN gl.[G_L Account No_] in ( '43030','43020') THEN gl.[Amount] ELSE 0 END),
        0
    ) AS [Full Maintenance GP_PCT]

FROM [Copyofproduction].[dbo].[Production$G_L Entry] gl

WHERE
    gl.[Posting Date] >= '2024-01-01'
    --AND gl.[Posting Date] <= '2026-03-31'
    AND gl.[G_L Account No_] IN ('43030','43020', '53030', '53020')
   -- AND gl.[Global Dimension 1 Code] in ('6','9')

group by 

DATEFROMPARTS(YEAR(gl.[Posting Date]), MONTH(gl.[Posting Date]), 1),
    gl.[Global Dimension 1 Code] 



--- rental st/lt maintenanace

 WITH GLBase AS
(
    SELECT
        DATEFROMPARTS(YEAR(GL.[Posting Date]), MONTH(GL.[Posting Date]), 1) AS MonthStart,
        GL.[G_L Account No_] AS GL_Account_No,
        GL.[Amount]
    FROM [Production$G_L Entry] GL
    WHERE GL.[G_L Account No_] IN
    (
        '45005', '45010', '45080', '45070',
        '55070', '55080',
        '45015', '45075',
        '55076', '55086'
    )
    AND GL.[Posting Date] >= '2024-01-01'
    -- AND GL.[Posting Date] < '2026-01-01'
),
Monthly AS
(
    SELECT
        MonthStart,

        -- ST/LT
        -SUM(CASE WHEN GL_Account_No IN ('45005', '45010', '45080', '45070') THEN [Amount] ELSE 0 END) AS STLT_Net_Revenue,
        SUM(CASE WHEN GL_Account_No IN ('55070', '55080') THEN [Amount] ELSE 0 END) AS STLT_Maintenance,

        -- Flex
        -SUM(CASE WHEN GL_Account_No IN ('45015', '45075') THEN [Amount] ELSE 0 END) AS Flex_Net_Revenue,
        SUM(CASE WHEN GL_Account_No IN ('55076', '55086') THEN [Amount] ELSE 0 END) AS Flex_Maintenance

    FROM GLBase
    GROUP BY MonthStart
)
SELECT
    MonthStart,

    STLT_Net_Revenue,
    STLT_Maintenance,
    CAST(STLT_Maintenance AS DECIMAL(18,6)) / NULLIF(CAST(STLT_Net_Revenue AS DECIMAL(18,6)), 0) AS STLT_Maintenance_Ratio,

    Flex_Net_Revenue,
    Flex_Maintenance,
    CAST(Flex_Maintenance AS DECIMAL(18,6)) / NULLIF(CAST(Flex_Net_Revenue AS DECIMAL(18,6)), 0) AS Flex_Maintenance_Ratio,

    -- Combined ST/LT + Flex
    (STLT_Net_Revenue + Flex_Net_Revenue) AS Combined_Net_Revenue,
    (STLT_Maintenance + Flex_Maintenance) AS Combined_Maintenance,
    CAST((STLT_Maintenance + Flex_Maintenance) AS DECIMAL(18,6))
        / NULLIF(CAST((STLT_Net_Revenue + Flex_Net_Revenue) AS DECIMAL(18,6)), 0) AS Combined_Maintenance_Ratio

FROM Monthly
ORDER BY MonthStart;   





---test 
select sum ([Amount])

 FROM [Production$G_L Entry] GL
 WHERE GL.[G_L Account No_] IN
    (
        '45005') and 
        [Posting Date] between '2026-02-01' and '2026-02-28'




--- Rental Revenue

SELECT 
                GL.[ELC Document No_] AS [GL Document Number],
                 GL.[Document No_] AS [GL Document Number sub] ,
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
             FROM [Production$G_L Entry] AS GL
             LEFT JOIN [Production$Sales Invoice Header] AS SIH ON SIH.No_ = GL.[Document No_]
             LEFT JOIN (
    SELECT DISTINCT [No_]
    FROM [Production$Rental Contract Header]
) AS RCH
    ON GL.[ELC Document No_] = RCH.[No_] and RCH.[Document Type] = 1

             LEFT JOIN [Production$Equipment Object] AS EO ON GL.[Equipment Object] = EO.No_
             WHERE 
                GL.[G_L Account No_] IN (
'45005','45010','45070','45080',
'45030',
'45020',
'45015','45075',
'45007',
'46057'
)
                and RCH.[Contract Type] NOT in ('4WPRLFTFIN','DOLC','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN')




--test 

--select  sum(GL.Amount)
SELECT 
                GL.[ELC Document No_] AS [GL Document Number],
                 GL.[Document No_] AS [GL Document Number sub] ,
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
 FROM [Production$G_L Entry] AS GL
             LEFT JOIN [Production$Sales Invoice Header] AS SIH ON SIH.No_ = GL.[Document No_]
          LEFT JOIN [Production$Rental Contract Header]
AS RCH
    ON GL.[ELC Document No_] LIKE RCH.[No_] + '%' and RCH.[Document Type] = 1
    --AND GL.[ELC Document No_] IS NOT NULL
   --LIKE RCH.[No_] + '%'

             LEFT JOIN [Production$Equipment Object] AS EO ON GL.[Equipment Object] = EO.No_
             WHERE 
                GL.[G_L Account No_] IN (
'45005','45010','45070','45080',
'45030',
'45020',
'45015','45075',
'45007',
'46057'
) and GL.[Posting Date] between  '2025-01-01' and '2025-12-31' and GL.[ELC Document No_] = 'MC038248'
              and RCH.[Contract Type] NOT in ('4WPRLFTFIN','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN')

----
SELECT SUM(GL.Amount)
FROM [Production$G_L Entry] AS GL
LEFT JOIN [Production$Sales Invoice Header] AS SIH
    ON SIH.[No_] = GL.[Document No_]
LEFT JOIN [Production$Equipment Object] AS EO
    ON GL.[Equipment Object] = EO.[No_]
WHERE GL.[G_L Account No_] IN
(
    '45005','45010','45070','45080',
    '45030',
    '45020',
    '45015','45075',
    '45007',
    '46057'
)
AND GL.[Posting Date] BETWEEN '2025-01-01' AND '2025-12-31'
AND NOT EXISTS
(
    SELECT 1
    FROM [Production$Rental Contract Header] AS RCH
    WHERE RCH.[No_] = GL.[ELC Document No_]
      --AND RCH.[Contract Type] IN ('4WPRLFTFIN','DOLC','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN')
);
---


--
SELECT
    RCH.[No_],
    COUNT(*) AS Cnt
FROM [Production$Rental Contract Header] AS RCH
GROUP BY RCH.[No_]
HAVING COUNT(*) > 1
ORDER BY Cnt DESC;



---
SELECT *
FROM [Production$Rental Contract Header] AS RCH
WHERE RCH.[No_] IN
(
    SELECT [No_]
    FROM [Production$Rental Contract Header]
    GROUP BY [No_]
    HAVING COUNT(*) > 1
)
ORDER BY RCH.[No_];

--
              select top 100 * from [Production$Rental Contract Header] 
              where [Contract Type] in ('4WPRLFTFIN','LEASETFS','LEASETFSGM','LTRMO','PRLFTFIN') and [Document Type] = 1

            --  select distinct [Document Type]  from [Production$Rental Contract Header] 




-----

---Rental Maintenance Cost from GLs 

SELECT   
      H.[Responsibility Center],GL.[G_L Account No_],
      H.[Service Type],
      GL.[Document No_] AS [GL Document Number sub],GL.[Description],

      CASE 
            WHEN GL.[G_L Account No_] IN ('55070','55080') 
                  THEN 'ST & LT'
            WHEN GL.[G_L Account No_] IN ('55030')  -- RERENT only is mentioned by Casey
                  THEN 'Sublets'
            WHEN GL.[G_L Account No_] IN ('55075','55085') 
                  THEN 'Used on Rent'
            WHEN GL.[G_L Account No_] IN ('55076','55086') 
                  THEN 'FLEX'
            ELSE 'OTHER'
      END AS [Rental Fleet Type Classification],

      GL.[Amount] AS [Rental Maintenance Cost],
      GL.[Posting Date]

FROM [Production$G_L Entry] AS GL 
left join [Copyofproduction].[dbo].[Production$Work Order Header] AS H
on H.[No_] = GL.[Work Order No_]
LEFT JOIN [Copyofproduction].[dbo].[Production$Work Order Line] AS L
       ON H.[No_] = L.[Document No_]
      AND H.[Responsibility Center] = L.[Responsibility Center]

WHERE H.[Posting Status] = '2' and GL.[Posting Date] >= '2025-01-01'
 /**AND H.[Service Type] IN (
        'RRENT','RPM','USEDRENTPM','USEDRENTAL','FLEXRENTAL','FLEXRENTPM',
        'RERENT','TIRE-RENT','RRERENT','RERENTPM',
        'TRANS-RENT','RCUSTREP','RDEL'
      ) **/ AND GL.[G_L Account No_] IN ('55070','55080','55075','55085','55076','55086','55030')

GROUP BY  
      H.[Responsibility Center], GL.[Document No_],GL.[G_L Account No_],
      H.[Service Type],
      GL.[Posting Date],
       CASE 
            WHEN GL.[G_L Account No_] IN ('55070','55080') 
                  THEN 'ST & LT'
            WHEN GL.[G_L Account No_] IN ('55030')  -- RERENT only is mentioned by Casey
                  THEN 'Sublets'
            WHEN GL.[G_L Account No_] IN ('55075','55085') 
                  THEN 'Used on Rent'
            WHEN GL.[G_L Account No_] IN ('55076','55086') 
                  THEN 'FLEX'
            ELSE 'OTHER'
      END ,GL.[Description]





      ----rental main cost test  main cost matches with ELC GPA

select 
H.[Responsibility Center],GL.[G_L Account No_],
      H.[Service Type],
      GL.[Document No_] AS [GL Document Number sub],GL.[Description],

      CASE 
            WHEN GL.[G_L Account No_] IN ('55070','55080') 
                  THEN 'ST & LT'
            WHEN GL.[G_L Account No_] IN ('55030')  -- RERENT only is mentioned by Casey
                  THEN 'Sublets'
            WHEN GL.[G_L Account No_] IN ('55075','55085') 
                  THEN 'Used on Rent'
            WHEN GL.[G_L Account No_] IN ('55076','55086') 
                  THEN 'FLEX'
            ELSE 'OTHER'
      END AS [Rental Fleet Type Classification],

      GL.[Amount] AS [Rental Maintenance Cost],
      GL.[Posting Date]
--SUM(GL.[Amount]) AS [Rental Maintenance Cost]
      FROM [Production$G_L Entry] AS GL 
left join [Copyofproduction].[dbo].[Production$Work Order Header] AS H
on H.[No_] = GL.[Work Order No_] and H.[Posting Status] = '2'
--LEFT JOIN [Copyofproduction].[dbo].[Production$Work Order Line] AS L
    --  ON H.[No_] = L.[Document No_] and H.[Service Type] =L.[Service Type]
    --AND H.[Responsibility Center] = L.[Responsibility Center]

WHERE 
--H.[Posting Status] = '2' and 
GL.[Posting Date] between '2026-03-01' and '2026-03-31' 
 /**AND H.[Service Type] IN (
        'RRENT','RPM','USEDRENTPM','USEDRENTAL','FLEXRENTAL','FLEXRENTPM',
        'RERENT','TIRE-RENT','RRERENT','RERENTPM',
        'TRANS-RENT','RCUSTREP','RDEL'
      ) **/ AND GL.[G_L Account No_] IN ('55070','55080','55075','55085','55076','55086')
      AND H.[No_] = 'S3157614'


     