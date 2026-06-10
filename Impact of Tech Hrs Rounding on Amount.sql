--- Final Tech Hrs Rounding with change log flag 


-- First CTE: HourLineRounding
WITH HourLineRounding AS (
    SELECT
        WOH.[No_] AS [Work Order],
        R.[Name] AS [Tech Name],
        WOL.[Service Report],
        SUM(CAST(HL.[Hours] AS DECIMAL(10, 5))) AS [Actual Hours],
        SUM(CEILING(HL.[Hours] * 4) / 4.0) AS [Rounded Actual Hours to .25],
        SUM(CEILING(HL.[Hours] * 2) / 2.0) AS [Rounded Actual Hours to .5]
    FROM 
        [Production$Work Order Line] AS WOL 
        LEFT JOIN [Production$Work Order Header] AS WOH
            ON WOL.[Document No_] = WOH.[No_]
        LEFT JOIN [Production$Hour Line] AS HL 
            ON HL.[Work Order No_] = WOL.[Document No_] 
            AND WOL.[Service Report] = HL.[Service Report]
        INNER JOIN [Production$Resource] AS R 
            ON HL.[Resource No_] = R.[No_]
    WHERE 
    WOH.[No_] ='S2978153' and 
        WOL.[Type] = 2
        AND HL.[Not Billable] = 0
    GROUP BY 
        WOH.[No_], R.[Name], HL.[Not Billable], WOL.[Service Report]
),

-- Second CTE: RankedChanges
RankedChanges AS (
    SELECT 
        [Primary Key Field 3 Value],
        [Primary Key Field 2 Value],
        [Date and Time],
        [Field No_],
        [Old Value],
        [New Value],
        ROW_NUMBER() OVER (
            PARTITION BY [Field No_], [Primary Key Field 3 Value], [Primary Key Field 2 Value]
            ORDER BY [Date and Time] DESC
        ) AS rn
    FROM [Production$Change Log Entry]
    WHERE [Table No_] = '11021609' -- Work Order Line
      AND [Date and Time] >= '2025-01-01'
      AND [Type of Change] = '1' -- Modify
      AND [Field No_] IN ('105', '110') -- Quantity Invoiced, Unit Price
      AND [Primary Key Field 2 Value] = 'S2978153' -- Work Order No
),

-- Third CTE: ChangeLog filtered by rn = 1
ChangeLog AS (
    SELECT 
        'Yes' as [Last Modified Flag],
        [Primary Key Field 3 Value],
        [Primary Key Field 2 Value],
        [Date and Time],
        [Field No_],
        [Old Value],
        [New Value]
    FROM RankedChanges
    WHERE rn = 1
)

-- Final SELECT
SELECT
    WOH.[Responsibility Center] AS [CSC],
    WOH.[No_] AS [Work Order],
    WOL.[Service Report],
    WOH.[Service Type],
    WOL.[No_] AS [Tech],
    HLR.[Tech Name],
    ROUND(CAST(WOL.[Unit Price] AS DECIMAL(10,2)),2) AS [WOL Tech Unit Price],
    ROUND(CAST(WOL.[Quantity Used] AS DECIMAL(10,2)),2) AS [WOL Expected Tech Hrs Posted from HL],
    ROUND(CAST(HLR.[Rounded Actual Hours to .25] AS DECIMAL(10,2)),2) AS [HL Expected Tech Hrs after Rounding to .25],
    ROUND(CAST(HLR.[Rounded Actual Hours to .5] AS DECIMAL(10,2)),2) AS [HL Expected Tech Hrs after Rounding to .5],
    ROUND(CAST(WOL.[Quantity Invoiced] AS DECIMAL(10,2)),2) AS [WOL Actual Tech Hrs Invoiced],
    
    -- Amounts
    ROUND(CAST((WOL.[Quantity Used] * WOL.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount before Rounding],
    ROUND(CAST((HLR.[Rounded Actual Hours to .25] * WOL.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount after Rounding to .25],
    ROUND(CAST((HLR.[Rounded Actual Hours to .5] * WOL.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount after Rounding to .5],
    ROUND(CAST(WOL.[Amount] AS DECIMAL(10,2)),2) AS [WOL Actual Amount Invoiced],

    -- Flags
    CASE 
        WHEN WOL.[Quantity Invoiced] < WOL.[Quantity Used] THEN 'Yes' 
        ELSE 'No' 
    END AS [Invoiced less Hrs?],

    CASE 
        WHEN WOL.[Amount] < (WOL.[Quantity Used] * WOL.[Unit Price]) THEN 'Yes' 
        ELSE 'No' 
    END AS [Invoiced less Amount?],

    -- % Variance calculations
    ROUND(
        CASE 
            WHEN (WOL.[Quantity Used] * WOL.[Unit Price]) = 0 THEN 0
            ELSE ((WOL.[Amount] - (WOL.[Quantity Used] * WOL.[Unit Price])) / (WOL.[Quantity Used] * WOL.[Unit Price])) 
        END, 2
    ) AS [% Variance Amount vs Expected (No Rounding)],

    ROUND(
        CASE 
            WHEN (HLR.[Rounded Actual Hours to .25] * WOL.[Unit Price]) = 0 THEN 0
            ELSE ((WOL.[Amount] - (HLR.[Rounded Actual Hours to .25] * WOL.[Unit Price])) / (HLR.[Rounded Actual Hours to .25] * WOL.[Unit Price])) 
        END, 2
    ) AS [% Variance Amount vs Expected (Rounded to .25)],

    ROUND(
        CASE 
            WHEN (HLR.[Rounded Actual Hours to .5] * WOL.[Unit Price]) = 0 THEN 0
            ELSE ((WOL.[Amount] - (HLR.[Rounded Actual Hours to .5] * WOL.[Unit Price])) / (HLR.[Rounded Actual Hours to .5] * WOL.[Unit Price])) 
        END, 2
    ) AS [% Variance Amount vs Expected (Rounded to .5)]
,CL.[Last Modified Flag]
,CL.[Date and Time] as [Modified DateTime],
CL.[Old Value],
CL.[New Value]
FROM 
    [Production$Work Order Header] AS WOH 
INNER JOIN 
    [Production$Work Order Line] AS WOL 
    ON WOH.[No_] = WOL.[Document No_]
LEFT JOIN 
    HourLineRounding AS HLR 
    ON WOL.[Document No_] = HLR.[Work Order] 
    AND WOL.[Service Report] = HLR.[Service Report]
left JOIN 
    ChangeLog AS CL
    ON WOL.[Document No_] = CL.[Primary Key Field 2 Value] 
    AND  CAST(REPLACE(WOL.[Line No_], ',', '') AS DECIMAL(18,2)) = CAST(REPLACE(CL.[Primary Key Field 3 Value], ',', '') AS DECIMAL(18,2))

WHERE 
WOH.[No_] = 'S2978153' and
    WOL.[Type] = 2
    AND WOL.[Work Type Code] LIKE '%CUST%' 
    AND WOH.[Document Type] = 1
    AND WOH.[Posting Date] >= '2024-01-01'
    AND WOH.[Posting Date] <= CAST(GETDATE() AS DATE)
    AND WOL.[Quantity Used] <> 0





/**--WO Labor Lines  
-- Structured Format
SELECT 
    WOL.[Document No_],
    WOH.[Service Type],
    WOH.[Posting Date],
    WOH.[Manufacturer Code],
    WOH.[Equipment Model],
    WOH.[Equipment Object],
    WOL.[No_],
    WOH.[Responsibility Center],
    WOL.[Quantity Used],
    WOL.[Quantity Invoiced],
    WOL.[Line Cost],
    WOL.[Unit Price],
    WOL.[Unit Cost],
    WOL.[Amount] - WOL.[Line Cost] AS Profit,
    WOL.[Amount],
    WOH.[Sell-to Customer No_],
    WOH.[Sell-to Customer Name],
    WOL.[Type],
    E.[Equipment Category]
FROM 
    [Production$Work Order Header] AS WOH
INNER JOIN 
    [Production$Work Order Line] AS WOL 
    ON WOH.[No_] = WOL.[Document No_]
INNER JOIN 
    [Production$Equipment Object] AS E 
    ON WOH.[Equipment Object] = E.[No_]
WHERE 
    WOH.[Document Type] = 1
    AND WOH.[Posting Date] >= '2022-01-01'   -- replace with your start date
    AND WOH.[Posting Date] <= '2024-12-31'   -- replace with your end date
    AND WOH.[Responsibility Center] IN ('RESP01', 'RESP02')  -- replace with actual centers
    AND (
        (WOL.[Type] = 2 AND WOL.[Quantity Used] <> 0)
        OR
        (WOL.[Type] = 5 AND WOL.[Quantity Used] = 0 AND WOL.[Amount] <> 0)
    )



--Labor Analysis
--Structured format 

SELECT 
    WOH.[Service Type],
    HL.[Resource No_],
    HL.[Starting Date],
    HL.[Finishing Date],
    HL.[Activity Code],
    HL.[Work Order No_],
    HL.[Work Type Code],
    CAST(HL.[Billable Hours] AS DECIMAL(10, 5)) AS [Rounded Bill Hours],
    CAST(HL.Hours AS DECIMAL(10, 5)) AS [Actual Hours],
    WOL.[Quantity Used] [WOL Quantity Used],
    WOL.[Quantity Invoiced] [WOL Quantity Invoiced],
    WOL.[Unit Price] [WOL Unit Price],
    WOL.[Amount] [WOL Amount],
    HL.[Responsibility Center],
    HL.[Payroll Code],
    SZ.[Service Zone],
    CAST(HL.[Starting Time] AS TIME) AS [Start Time],
    CAST(HL.[Finishing Time] AS TIME) AS [Finish Time],
    CASE HL.[Not Billable] WHEN 0 THEN 'Billable' ELSE 'Non-Billable' END AS Billable,
    R.[Name],
    R.[Resource Group No_],
    L.[Zone],
    HL.[Bill-to Customer Name],
    R.[Service Van]
FROM 
[Production$Work Order Header] AS WOH 
INNER JOIN 
    [Production$Work Order Line] AS WOL 
    ON WOH.[No_] = WOL.[Document No_]
left join [Production$Hour Line] AS HL ON HL.[Work Order No_] = WOH.[No_]
INNER JOIN 
    Production$Resource AS R ON HL.[Resource No_] = R.[No_]
INNER JOIN 
    Production$Location AS L ON R.[Service Van] = L.[Code]
LEFT JOIN 
    [Production$Service Zones per Resource] AS SZ ON HL.[Resource No_] = SZ.[No_]
WHERE 
 HL.[Work Order No_]='S2939379' 
and WOL.[Type] = 2
    --CAST(HL.[Starting Date] AS DATE) > CAST(DATEADD(DAY, -1, GETDATE()) AS DATE)
    --AND HL.[Responsibility Center] IN (@CSC)




-- Part 1-- WOL,WOH FOR tECH hRS AND ROUNDING

with HourLineRounding as (
SELECT
    HL.[Work Order No_],
    SUM(CAST(HL.[Hours] AS DECIMAL(10, 5))) AS [Actual Hours],
    SUM(CAST(HL.[Billable Hours] AS DECIMAL(10, 5))) AS [Rounded Bill Hours],
    SUM(CEILING(HL.[Hours] * 4) / 4.0) AS [Rounded Actual Hours to .25]
FROM 
    [Production$Work Order Header] AS WOH
INNER JOIN 
    [Production$Work Order Line] AS WOL 
    ON WOH.[No_] = WOL.[Document No_]
LEFT JOIN 
    [Production$Hour Line] AS HL 
    ON HL.[Work Order No_] = WOH.[No_]
INNER JOIN 
    [Production$Resource] AS R 
    ON HL.[Resource No_] = R.[No_]
INNER JOIN 
    [Production$Location] AS L 
    ON R.[Service Van] = L.[Code]
LEFT JOIN 
    [Production$Service Zones per Resource] AS SZ 
    ON HL.[Resource No_] = SZ.[No_]
WHERE 
    HL.[Work Order No_] = 'S2939379' AND
    WOL.[Type] = 2
GROUP BY 
    HL.[Work Order No_]) 

select
    WOH.[No_] as [Work Order],
    WOH.[Service Type],
    round(cast(WOL.[Unit Price] as decimal(10,2)),2) [WOL Tech Unit Price],
    round(cast(WOL.[Quantity Used] as decimal(10,2)),2) [WOL Expecetd Tech Hrs Posted from HL],
    round(cast(HLR.[Rounded Actual Hours to .25] as decimal(10,2)),2) [HL Expected Tech Hrs after Rounding to .25],
    round(cast(HLR.[Rounded Bill Hours] as decimal(10,2)),2) [HL Expected Tech Hrs after Rounding to .5],
    round(cast(WOL.[Quantity Invoiced] as decimal(10,2)),2) [WOL Actual Tech Hrs Invoiced],
    round(cast((WOL.[Quantity Used]* WOL.[Unit Price]) as decimal(10,2)),2) AS [Expected Tech Amount before Rounding],
    round(cast((HLR.[Rounded Actual Hours to .25]*WOL.[Unit Price]) as decimal(10,2)),2) as [Expected Tech Amount after Rounding to .25],
    round(cast((HLR.[Rounded Bill Hours]*WOL.[Unit Price]) as decimal(10,2)),2) as [Expected Tech Amount after Rounding to .5],
    --(WOL.[Quantity Invoiced]*WOL.[Unit Price]) as [Actual Tech Amount Invoiced],
    round(cast(WOL.[Amount] as decimal(10,2)),2) [WOL Actual Amount Invoiced] 
FROM 
[Production$Work Order Header] AS WOH 
INNER JOIN 
    [Production$Work Order Line] AS WOL 
    ON WOH.[No_] = WOL.[Document No_]
LEFT JOIN HourLineRounding AS HLR 
on WOL.[Document No_]=HLR.[Work Order No_]
WHERE 
WOH.[No_] ='S2939379' 
and WOL.[Type] = 2

-- 
--Part 2 --
with HourLineRounding as (
SELECT
    HL.[Work Order No_],
    SUM(CAST(HL.[Billable Hours] AS DECIMAL(10, 5))) AS [Rounded Bill Hours],
    SUM(CAST(HL.[Hours] AS DECIMAL(10, 5))) AS [Actual Hours]
FROM 
    [Production$Work Order Header] AS WOH
INNER JOIN 
    [Production$Work Order Line] AS WOL 
    ON WOH.[No_] = WOL.[Document No_]
LEFT JOIN 
    [Production$Hour Line] AS HL 
    ON HL.[Work Order No_] = WOH.[No_]
INNER JOIN 
    [Production$Resource] AS R 
    ON HL.[Resource No_] = R.[No_]
INNER JOIN 
    [Production$Location] AS L 
    ON R.[Service Van] = L.[Code]
LEFT JOIN 
    [Production$Service Zones per Resource] AS SZ 
    ON HL.[Resource No_] = SZ.[No_]
WHERE 
    HL.[Work Order No_] = 'S2939379' AND
    WOL.[Type] = 2
GROUP BY 
    HL.[Work Order No_])





--WO Labor used Vs Invoiced

--Structured Format 

SELECT 
    WOH.[Order Date] AS Work_Order_HeaderOrderDate,
    WOH.[Responsibility Center] AS Work_Order_HeaderResponsibilityCenter,
    WOH.[Posting Date] AS Work_Order_HeaderPostingDate,
    SUM(CAST(WOL.[Quantity Used] AS DECIMAL(10, 2))) AS Work_Order_LineQuantityUsed,
    SUM(CAST(WOL.[Quantity Invoiced] AS DECIMAL(10, 2))) AS Work_Order_LineQuantityInvoiced,
    CASE WOL.[Type]
        WHEN 0 THEN ' '
        WHEN 1 THEN 'Item'
        WHEN 2 THEN 'Resource'
        WHEN 3 THEN 'Charge'
        WHEN 4 THEN ''
        WHEN 5 THEN 'Job Code'
        WHEN 6 THEN 'Purchase'
        WHEN 7 THEN 'Object'
        WHEN 8 THEN 'Model'
        WHEN 9 THEN 'Group(Resource)'
        WHEN 10 THEN 'Rental'
        WHEN 11 THEN 'Transport'
        ELSE ''
    END AS Work_Order_LineType,
    SUM(CAST(WOL.[Quantity Used] - WOL.[Quantity Invoiced] AS DECIMAL(10, 2))) AS Difference,
    WOL.[No_] AS Resource,
    WOH.[Service Type],
    WOH.[No_],
    WOH.[Posting Date],
    WOL.[Type],
    WOH.[Document Type],
    WOL.[Responsibility Center] AS Work_Order_LineResponsibilityCenter,
    WOL.[Document No_] AS Work_Order_LineDocumentNo_,
    WOH.[Sell-to Customer Name]
FROM 
    [Production$Work Order Header] AS WOH
INNER JOIN 
    [Production$Work Order Line] AS WOL ON WOL.[Document No_] = WOH.[No_]
INNER JOIN 
    Production$Customer AS C ON C.[No_] = WOH.[Sell-to Customer No_]
INNER JOIN 
    [Production$Equipment Object] AS E ON E.[No_] = WOH.[Equipment Object]
WHERE 
    WOL.[Type] = 2
    AND WOH.[Document Type] = 1
GROUP BY 
    WOH.[Order Date],
    WOH.[Responsibility Center],
    WOH.[Posting Date],
    WOH.[Service Type],
    WOL.[No_],
    WOH.[No_],
    CASE WOL.[Type]
        WHEN 0 THEN ' '
        WHEN 1 THEN 'Item'
        WHEN 2 THEN 'Resource'
        WHEN 3 THEN 'Charge'
        WHEN 4 THEN ''
        WHEN 5 THEN 'Job Code'
        WHEN 6 THEN 'Purchase'
        WHEN 7 THEN 'Object'
        WHEN 8 THEN 'Model'
        WHEN 9 THEN 'Group(Resource)'
        WHEN 10 THEN 'Rental'
        WHEN 11 THEN 'Transport'
        ELSE ''
    END,
    WOH.[Document Type],
    WOL.[Type],
    WOL.[Responsibility Center],
    WOL.[Document No_],
    WOH.[Sell-to Customer Name]
HAVING 
    WOH.[Posting Date] >= DATEADD(WEEK, -1, GETDATE())
    AND WOH.[Posting Date] < GETDATE()
    AND WOH.[Service Type] NOT IN ('CBRONZEPM', 'T360PM')
    --AND WOH.[Responsibility Center] IN (@rep)
    AND SUM(CAST(WOL.[Quantity Used] - WOL.[Quantity Invoiced] AS DECIMAL(10, 2))) <> 0
ORDER BY 
    Work_Order_HeaderResponsibilityCenter,
    WOH.[No_]


**/


--TEST 


--SELECT TOP 100 * FROM[Production$Resource]
--WHERE [Work Order No_] ='S2939379'




-- Final Query with variance % befor and after rounding to .25 /.5 

WITH HourLineRounding AS (
    SELECT
     WOH.[No_] [Work Order],
   R.[Name] [Tech Name],
   WOL.[Service Report],
       
        SUM(CAST(HL.[Hours] AS DECIMAL(10, 5))) AS [Actual Hours],
        --SUM(CAST(HL.[Billable Hours] AS DECIMAL(10, 2))) AS [Rounded Bill Hours],
        SUM(CEILING(HL.[Hours] * 4) / 4.0) AS [Rounded Actual Hours to .25],
        SUM(CEILING(HL.[Hours] * 2) / 2.0) AS [Rounded Actual Hours to .5]
        --CASE HL.[Not Billable] WHEN 0 THEN 'Billable' ELSE 'Non-Billable' END AS Billable
    FROM 
     
          
               [Production$Work Order Line] AS WOL 
 LEFT JOIN 
    [Production$Work Order Header] AS WOH
        ON WOL.[Document No_] = WOH.[No_]

                LEFT JOIN 
               [Production$Hour Line] AS HL 
        ON HL.[Work Order No_] = WOL.[Document No_] and WOL.[Service Report] = HL.[Service Report]

    
       
   INNER JOIN 
       [Production$Resource] AS R 
       ON HL.[Resource No_] = R.[No_]
   -- INNER JOIN 
       -- [Production$Location] AS L 
       -- ON R.[Service Van] = L.[Code]
   -- LEFT JOIN 
       -- [Production$Service Zones per Resource] AS SZ 
        --ON HL.[Resource No_] = SZ.[No_]
    WHERE 
        --HL.[Work Order No_] = 'S2834666' AND
        WOL.[Type] = 2
        AND HL.[Not Billable] = 0
    GROUP BY 
         WOH.[No_],R.[Name], HL.[Not Billable], WOL.[Service Report]
) 
, ChangeLog as 
(
 with RankedChanges AS (
    SELECT 
        [Primary Key Field 3 Value],
        [Primary Key Field 2 Value],
        [Date and Time],
        [Field No_],
        [Old Value],
        [New Value],
        ROW_NUMBER() OVER (
            PARTITION BY [Field No_] 
            ORDER BY [Date and Time] DESC
        ) AS rn
    FROM [Production$Change Log Entry]
    WHERE [Table No_] = '11021609' -- Work Order Line
      AND [Date and Time] >= '2025-01-01'
      AND [Type of Change] = '1' -- Modify
      AND [Field No_] IN ('105', '110') -- Quantity Invoiced, Unit Price
      AND [Primary Key Field 2 Value] = 'S2939379' -- Work Order No
)

SELECT 
    [Primary Key Field 3 Value],
    [Primary Key Field 2 Value],
    [Date and Time],
    [Field No_],
    [Old Value],
    [New Value]
FROM RankedChanges
WHERE rn = 1)

SELECT
    WOH.[Responsibility Center] [CSC],
    WOH.[No_] AS [Work Order],
    WOL.[Service Report],
    WOH.[Service Type],
    WOL.[No_] as [Tech],
    HLR.[Tech Name],
    ROUND(CAST(WOL.[Unit Price] AS DECIMAL(10,2)),2) AS [WOL Tech Unit Price],
    ROUND(CAST(WOL.[Quantity Used] AS DECIMAL(10,2)),2) AS [WOL Expected Tech Hrs Posted from HL],
    ROUND(CAST(HLR.[Rounded Actual Hours to .25] AS DECIMAL(10,2)),2) AS [HL Expected Tech Hrs after Rounding to .25],
    ROUND(CAST(HLR.[Rounded Actual Hours to .5] AS DECIMAL(10,2)),2) AS [HL Expected Tech Hrs after Rounding to .5],
    ROUND(CAST(WOL.[Quantity Invoiced] AS DECIMAL(10,2)),2) AS [WOL Actual Tech Hrs Invoiced],
    
    -- Amounts
    ROUND(CAST((WOL.[Quantity Used] * WOL.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount before Rounding],
    ROUND(CAST((HLR.[Rounded Actual Hours to .25] * WOL.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount after Rounding to .25],
    ROUND(CAST((HLR.[Rounded Actual Hours to .5] * WOL.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount after Rounding to .5],
    ROUND(CAST(WOL.[Amount] AS DECIMAL(10,2)),2) AS [WOL Actual Amount Invoiced],

    -- Flags
    CASE 
        WHEN WOL.[Quantity Invoiced] < WOL.[Quantity Used] THEN 'Yes' 
        ELSE 'No' 
    END AS [Invoiced less Hrs?],

    CASE 
        WHEN WOL.[Amount] < (WOL.[Quantity Used] * WOL.[Unit Price]) THEN 'Yes' 
        ELSE 'No' 
    END AS [Invoiced less Amount?],

    -- % Variance calculations
    ROUND(
        CASE 
            WHEN (WOL.[Quantity Used] * WOL.[Unit Price]) = 0 THEN 0
            ELSE ((WOL.[Amount] - (WOL.[Quantity Used] * WOL.[Unit Price])) / (WOL.[Quantity Used] * WOL.[Unit Price])) 
        END, 2
    ) AS [% Variance Amount vs Expected (No Rounding)],

    ROUND(
        CASE 
           WHEN (HLR.[Rounded Actual Hours to .25] * WOL.[Unit Price]) = 0 THEN 0
            ELSE ((WOL.[Amount] - (HLR.[Rounded Actual Hours to .25] * WOL.[Unit Price])) / (HLR.[Rounded Actual Hours to .25] * WOL.[Unit Price])) 
        END, 2
    ) AS [% Variance Amount vs Expected (Rounded to .25)],

    ROUND(
        CASE 
            WHEN (HLR.[Rounded Actual Hours to .5] * WOL.[Unit Price]) = 0 THEN 0
            ELSE ((WOL.[Amount] - (HLR.[Rounded Actual Hours to .5] * WOL.[Unit Price])) / (HLR.[Rounded Actual Hours to .5] * WOL.[Unit Price])) 
        END, 2
    ) AS [% Variance Amount vs Expected (Rounded to .5)]

FROM 
    [Production$Work Order Header] AS WOH 
INNER JOIN 
    [Production$Work Order Line] AS WOL 
    ON WOH.[No_] = WOL.[Document No_]
LEFT JOIN 
    HourLineRounding AS HLR 
    ON WOL.[Document No_] = HLR.[Work Order] and WOL.[Service Report] = HLR.[Service Report]
inner join Changelog CL
    ON WOL.[Document No_] = CL.[Primary Key Field 2 Value] 
    and WOL.[Line No_] = CAST(CL.[Primary Key Field 3 Value] AS DECIMAL(18, 2))

WHERE 
    --WOH.[No_] = 'S2834666' 
    WOL.[Type] = 2
    and WOL.[Work Type Code] like '%CUST%'  ---- JOIN INTERNAL/EXTERNAL
    and WOH.[Document Type] = 1
    AND WOH.[Posting Date] >= '2024-01-01'   -- replace with your start date
    AND WOH.[Posting Date] <= CAST(GETDATE() AS DATE)   -- replace with your end date
    --AND WOH.[Responsibility Center] IN ('RESP01', 'RESP02')  -- replace with actual centers
    AND 
        WOL.[Type] = 2 AND WOL.[Quantity Used] <> 0
        --AND HLR.[Billable] = 'Billable'
    ;


--internal external billed 
SELECT TOP (1000) [Code]
      ,[Type]
  FROM [Copyofproduction ].[dbo].[IntExtBilledService]

--test billable and not billable 
 SELECT DISTINCT HL.[Activity Code]  FROM 
        [Production$Work Order Header] AS WOH
    INNER JOIN 
        [Production$Work Order Line] AS WOL 
        ON WOH.[No_] = WOL.[Document No_]
    LEFT JOIN 
        [Production$Hour Line] AS HL 
        ON HL.[Work Order No_] = WOH.[No_]
 where HL.[Not Billable] = 1 and WOL.[Type] = 2


 SELECT TOP 100 * FROM [Production$Work Order Line] WHERE  [Document No_] ='S2939379'



 --change log query 

SELECT [Primary Key Field 2 Value]
--,max([Date and Time]) as [Date and Time]
, [Field No_],[Old Value]
, [New Value]
FROM [Production$Change Log Entry]
WHERE [Table No_] = '11021609' --Work Order Line
AND [Date and Time] >= '1/1/2024'
--AND [Primary Key Field 3 Value] = Work Order Line Number
AND [Type of Change] = '1' --Modify
AND [Field No_] IN ('105', '110')--Quantity Invoiced 110 --Unit Price
AND [Primary Key Field 2 Value] = 'S2635813' -- Work order No
--group by [Primary Key Field 2 Value],[Field No_], [Old Value], [New Value]
 

 --CTE for max date time in cange log for field No

with ChangeLog as (
 WITH RankedChanges AS (
    SELECT 
        [Primary Key Field 3 Value],
        [Primary Key Field 2 Value],
        [Date and Time],
        [Field No_],
        [Old Value],
        [New Value],
        ROW_NUMBER() OVER (
            PARTITION BY [Field No_] 
            ORDER BY [Date and Time] DESC
        ) AS rn
    FROM [Production$Change Log Entry]
    WHERE [Table No_] = '11021609' -- Work Order Line
      AND [Date and Time] >= '2024-01-01'
      AND [Type of Change] = '1' -- Modify
      AND [Field No_] IN ('105', '110') -- Quantity Invoiced, Unit Price
      AND [Primary Key Field 2 Value] = 'S2635813' -- Work Order No
)

SELECT 
'yes' as [Last Modified],
    [Primary Key Field 3 Value],
    [Primary Key Field 2 Value],
    [Date and Time],
    [Field No_],
    [Old Value],
    [New Value]
FROM RankedChanges
WHERE rn = 1)

 
 --tEST Change Log Join WOL
SELECT *
FROM 
[Production$Work Order Line] WOL inner join
[Production$Change Log Entry] CL
--on WOL.[Line No_] = CAST(CL.[Primary Key Field 3 Value] AS DECIMAL(18, 2))
ON CAST(REPLACE(WOL.[Line No_], ',', '') AS DECIMAL(18,2)) = CAST(REPLACE(CL.[Primary Key Field 3 Value], ',', '') AS DECIMAL(18,2))
WHERE CL.[Table No_] = '11021609' --Work Order Line
AND CL.[Date and Time] >= '1/1/2025'
--AND [Primary Key Field 3 Value] = Work Order Line Number
AND CL.[Type of Change] = '1' --Modify
AND CL.[Field No_] IN ('105', '110')--Quantity Invoiced 110 --Unit Price
AND CL.[Primary Key Field 2 Value] = 'S2939379' -- Work order No



