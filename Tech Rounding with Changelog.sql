-- First CTE: HourLineRounding
WITH HourLineRounding AS (
    SELECT
        WOH.[No_] AS [Work Order],
       -- R.[Name] AS [Tech Name],
        WOL.[Service Report],
        HL.[Resource No_],
        WOL.[No_] [Resource Code],
        SUM(CAST(WOL.[Quantity Used] AS DECIMAL(10, 5))) AS [Actual Hours],
        SUM(CEILING(HL.[Hours] * 4) / 4.0) AS [Rounded Actual Hours to .25],
        SUM(CEILING(HL.[Hours] * 2) / 2.0) AS [Rounded Actual Hours to .5]
    FROM 
    [Production$Work Order Header] AS WOH
        LEFT JOIN [Production$Work Order Line] AS WOL 
            ON WOL.[Document No_] = WOH.[No_]
        LEFT JOIN [Production$Hour Line] AS HL 
            ON HL.[Work Order No_] = WOL.[Document No_] 
            AND WOL.[Service Report] = HL.[Service Report] 
            and HL.[Resource No_]=WOL.[No_]
        INNER JOIN [Production$Resource] AS R 
           ON HL.[Resource No_] = R.[No_]
    WHERE 
    WOH.[No_] ='S2906766' and 
        WOL.[Type] = 2
        AND WOL.[Work Type Code] LIKE '%CUST%' 
        AND WOH.[Document Type] = 1
        --AND HL.[Not Billable] = 0
    GROUP BY 
        WOH.[No_], WOL.[Service Report],  
        HL.[Not Billable],HL.[Resource No_], 
        WOL.[No_],WOL.[Quantity Used]
)
,

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
      AND [Date and Time] >= '2024-01-01'
      AND [Type of Change] = '1' -- Modify
      AND [Field No_] IN ('105', '110') -- Quantity Invoiced, Unit Price
      AND [Primary Key Field 2 Value] = 'S2906766' -- Work Order No
)
,

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
    --HLR.[Tech Name],
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
    --AND WOL.[Service Report] = HLR.[Service Report] 
    and HLR.[Resource No_] = WOL.[No_]
left JOIN 
    ChangeLog AS CL
    ON WOL.[Document No_] = CL.[Primary Key Field 2 Value] 
    AND  CAST(REPLACE(WOL.[Line No_], ',', '') AS DECIMAL(18,2)) = CAST(REPLACE(CL.[Primary Key Field 3 Value], ',', '') AS DECIMAL(18,2))

WHERE 
WOH.[No_] = 'S2906766' and
    WOL.[Type] = 2
    AND WOL.[Work Type Code] LIKE '%CUST%' 
    AND WOH.[Document Type] = 1
    AND WOH.[Posting Date] >= '2024-01-01'
    AND WOH.[Posting Date] <= CAST(GETDATE() AS DATE)
    AND WOL.[Quantity Used] <> 0




-- /*************************** Final query tech rounding  *********************************/TEST 

-- CTE for WOL aggregation
WITH WOL_Agg AS (
    SELECT
     WOL.[Responsibility Center] AS [CSC],
        WOL.[Document No_],
     WOH.[Service Type],
        --CAST(REPLACE(WOL.[Line No_], ',', '') AS DECIMAL(18,2)) [Line No_],
        WOL.[No_] AS [Resource Code],
        WOH.[Posting Date],
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
       --WOH.[No_] = 'S2870988' AND
         WOL.[Type] = 2
        AND WOL.[Work Type Code] LIKE '%CUST%' 
        AND WOH.[Document Type] = 1
       and CB.[Type] = 'Customer Billed'
       AND WOH.[Posting Date] >= '2024-01-01'
    AND WOH.[Posting Date] <= CAST(GETDATE() AS DATE)
    AND WOL.[Quantity Used] <> 0

    GROUP BY 
        WOL.[No_],WOL.[Document No_],[Unit Price],
        --,WOL.[Quantity Invoiced]
        WOH.[Service Type],WOL.[Responsibility Center],WOH.[Posting Date]
),

-- CTE for HL aggregation
HL_Agg AS (
    SELECT
        HL.[Resource No_] AS [Resource Code] ,
        --HL.[Work Order No_],
        HL.[Work Order No_] ,
        SUM(CEILING(HL.[Hours] * 4) / 4.0) AS [Rounded Hours to .25],
        SUM(CEILING(HL.[Hours] * 2) / 2.0) AS [Rounded Hours to .5]
    FROM 
        [Production$Hour Line] AS HL
    WHERE 
        HL.[Not Billable] = 0  AND HL.[Work Type Code] LIKE '%CUST%' 
        --AND  HL.[Starting DateTime] >= '2025-01-01'
       --AND HL.[Work Order No_] = 'S2870988'
    GROUP BY 
        HL.[Resource No_],HL.[Work Order No_]
)


-- Final join
SELECT
    W.[CSC],
    W.[Service Type],
    W.[Document No_],
    W.[Posting Date],
    W.[Resource Code],
    --W.[Line No_],
    W.[Unit Price],
    W.[Total Quantity Used] [Total Tech Hrs Clocked],
    cast(H.[Rounded Hours to .25] as decimal (10,4)) [Expected Hrs when Rounded to .25],
    cast(H.[Rounded Hours to .5] as decimal (10,4)) [Expected Hrs when Rounded to .5],
    CAST(W.[Total Quantity Invoiced] AS DECIMAL(10,4)) [Total Tech Hrs Invoiced],
    ROUND(CAST((W.[Total Quantity Used] * W.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount before Rounding],
   ROUND(CAST((H.[Rounded Hours to .25] * W.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount after Rounding to .25],
    ROUND(CAST((H.[Rounded Hours to .5] * W.[Unit Price]) AS DECIMAL(10,2)),2) AS [Expected Tech Amount after Rounding to .5],
    ROUND(CAST(W.[Amount] AS DECIMAL(10,2)),2) AS [WOL Actual Amount Invoiced],
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
        END, 2
    AS [% Variance Amount vs Expected (No Rounding)],

    
        CASE 
            WHEN (H.[Rounded Hours to .25] * W.[Unit Price]) = 0 THEN 0
            ELSE ((W.[Amount] - (H.[Rounded Hours to .25] * W.[Unit Price])) / (H.[Rounded Hours to .25] * W.[Unit Price])) 
        END, 2
    AS [% Variance Amount vs Expected (Rounded to .25)],

  
        CASE 
            WHEN (H.[Rounded Hours to .5] * W.[Unit Price]) = 0 THEN 0
            ELSE ((W.[Amount] - (H.[Rounded Hours to .5] * W.[Unit Price])) / (H.[Rounded Hours to .5] * W.[Unit Price])) 
        END, 2
     AS [% Variance Amount vs Expected (Rounded to .5)]

FROM 
    WOL_Agg W
    LEFT JOIN HL_Agg H 
        ON W.[Resource Code] = H.[Resource Code] 
        AND H.[Work Order No_] = W.[Document No_]
    
    

/***************************CHANGE LOG QUERY *********************************/
--CHANGE LOG QUERY 
WITH RankedChanges AS (
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
      AND [Field No_] IN ('105', '110', '293') -- Quantity Invoiced, Unit Price, work type code
      --AND [Primary Key Field 2 Value] = 'S3001475' -- Work Order No
)
,

-- Third CTE: ChangeLog filtered by rn = 1
ChangeLog AS (
    SELECT 
       'Yes' as [Last Modified Flag],
       [Primary Key Field 3 Value],
        [Primary Key Field 2 Value],
        [Field No_],
       [Date and Time],
       --[Field No_],
        [Old Value],
        [New Value]
    FROM RankedChanges
   WHERE rn = 1
)

SELECT 
CL.[Primary Key Field 2 Value],
WOL.[No_] AS [Resource Code],
CAST(REPLACE(CL.[Primary Key Field 3 Value], ',', '') AS DECIMAL(18,2)) [line No_],
case when CL.[Field No_] = '293' THEN 'Work Type Code'
when CL.[Field No_] = '105' THEN 'Hrs Invoiced'
when CL.[Field No_] = '110' THEN 'Unit Price'
else 'Other' END AS [Modified Field],
CL.[Last Modified Flag],
CL.[Field No_],
 cast(WOH.[Posting Date] as date) as [Posting Date]
,max(CL.[Date and Time]) as [Modified DateTime],
CL.[Old Value],
CL.[New Value],
 CAST(WOL.[Quantity Used] AS DECIMAL(10, 5)) AS [Quantity Used],
CAST(WOL.[Quantity Invoiced] AS DECIMAL(10,5)) AS [Quantity Invoiced],
           WOL.[Unit Price] as [Unit Price],  -- bring this column with 
          WOL.[Amount] as [Amount], (CAST(WOL.[Quantity Used] AS DECIMAL(10, 5))*WOL.[Unit Price] ) AS [Expecetd Amount],
          WOL.[Amount]-(CAST(WOL.[Quantity Used] AS DECIMAL(10, 5))*WOL.[Unit Price] ) as Variance

FROM  [Production$Work Order Header] AS WOH
        LEFT JOIN [Production$Work Order Line] AS WOL 
            ON WOL.[Document No_] = WOH.[No_]
LEFT JOIN ChangeLog AS CL 
ON WOL.[Document No_] = CL.[Primary Key Field 2 Value] 
    AND  CAST(REPLACE(WOL.[Line No_], ',', '') AS DECIMAL(18,2)) = CAST(REPLACE(CL.[Primary Key Field 3 Value], ',', '') AS DECIMAL(18,2))
WHERE WOH.[Posting Date] > '01/01/2024' and WOL.[Type] = '2' and CL.[Primary Key Field 2 Value] <> '' AND WOL.[Work Type Code] LIKE '%CUST%' 
and CL.[Primary Key Field 2 Value] = 'S2759703'
group by 
CL.[Primary Key Field 2 Value],
WOL.[No_] , CL.[Field No_], CL.[Last Modified Flag],CL.[Field No_],CL.[Old Value],
CL.[New Value],CL.[Primary Key Field 3 Value],WOH.[Posting Date],WOL.[Quantity Used],WOL.[Quantity Invoiced],WOL.[Unit Price],WOL.[Amount]


--
select top 100*
 FROM [Production$Change Log Entry]
 WHERE [Table No_] = '11021609' and [New Value] like '%CUST%' and [Primary Key Field 2 Value] = 'S3001475'




 ---------------------------------Test MODIFIED TO FIX THE UNIT PRICE ERROR---------------------------------------------------------------- 


 WITH WOL_Agg AS (
    SELECT
     WOL.[Responsibility Center] AS [CSC],
        WOL.[Document No_],
     WOH.[Service Type],
     WOL.[Service Report],
     WOL.[Work Type Code],
     cast(WOH.[Posting Date] as date) as [Posting Date],
        CAST(REPLACE(WOL.[Line No_], ',', '') AS DECIMAL(18,2)) [Line No_],
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
       WOH.[No_] = 'S3001475' AND
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
        ,WOL.[Line No_]
),

-- CTE for HL aggregation
HL_Agg AS (
    SELECT
        HL.[Resource No_] AS [Resource Code] ,
        --HL.[Work Order No_],
        HL.[Service Report],
        HL.[Work Order No_] ,
        SUM(HL.[Hours]) AS Hours,
        SUM(CEILING(HL.[Hours] * 4) / 4.0) AS [Rounded Hours to .25],
        SUM(CEILING(HL.[Hours] * 2) / 2.0) AS [Rounded Hours to .5]
    FROM 
        [Production$Hour Line] AS HL
    WHERE 
        HL.[Not Billable] = 0  AND HL.[Work Type Code] LIKE '%CUST%' 
        --AND  HL.[Starting DateTime] >= '2025-02-12'
      --AND HL.[Work Order No_] = 'S3001475'
    GROUP BY 
        HL.[Resource No_],HL.[Work Order No_],HL.[Service Report]
        --,HL.[Hours]
)


-- Final join
SELECT
    W.[CSC],
    W.[Service Type],
    W.[Document No_],
    W.[Resource Code],
    W.[Service Report],
    W.[Work Type Code],
    --W.[Posting Date],
    W.[Line No_],
    W.[Unit Price],
    W.[Total Quantity Used] [Total Tech Hrs Clocked],
    cast(H.[Rounded Hours to .25] as decimal (10,4)) [Expected Hrs when Rounded to .25],
    cast(H.[Rounded Hours to .5] as decimal (10,4)) [Expected Hrs when Rounded to .5],
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





---pbi query actual

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
        --CAST(REPLACE(WOL.[Line No_], ',', '') AS DECIMAL(18,2)) [Line No_],
        WOL.[No_] AS [Resource Code],
        WOH.[Posting Date],
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
       --WOH.[No_] = 'S2971004' AND
         WOL.[Type] = 2
        AND WOL.[Work Type Code] LIKE '%CUST%' 
        AND WOH.[Document Type] = 1
       and CB.[Type] = 'Customer Billed'
       AND WOH.[Posting Date] >= '2024-01-01'
    AND WOH.[Posting Date] <= CAST(GETDATE() AS DATE)
    AND WOL.[Quantity Used] <> 0

    GROUP BY 
        WOL.[No_],WOL.[Document No_],[Unit Price],
        --,WOL.[Quantity Invoiced]
        WOH.[Service Type],WOL.[Responsibility Center]
        ,WOH.[Posting Date]
),

-- CTE for HL aggregation
HL_Agg AS (
    SELECT
        HL.[Resource No_] AS [Resource Code] ,
        --HL.[Work Order No_],
        HL.[Work Order No_] ,
        SUM(CEILING(HL.[Hours] * 4) / 4.0) AS [Rounded Hours to .25],
        SUM(CEILING(HL.[Hours] * 2) / 2.0) AS [Rounded Hours to .5]
    FROM 
        [Production$Hour Line] AS HL
    WHERE 
        HL.[Not Billable] = 0  AND HL.[Work Type Code] LIKE '%CUST%' 
        --AND  HL.[Starting DateTime] >= '2024-01-01'
       --AND HL.[Work Order No_] = 'S2971004'
    GROUP BY 
        HL.[Resource No_],HL.[Work Order No_]
)


-- Final join
SELECT
    W.[CSC],
    W.[CSC_Name],
    W.[Service Type],
    W.[Document No_],
    W.[Resource Code],
    W.[Posting Date],
    --W.[Line No_],
    W.[Unit Price],
    W.[Total Quantity Used] [Total Tech Hrs Clocked],
    cast(H.[Rounded Hours to .25] as decimal (10,4)) [Expected Hrs when Rounded to .25],
    cast(H.[Rounded Hours to .5] as decimal (10,4)) [Expected Hrs when Rounded to .5],
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
        WHEN W.[Amount] < (W.[Total Quantity Used] * W.[Unit Price]) THEN 'Write Down' 
        WHEN W.[Amount] > (W.[Total Quantity Used] * W.[Unit Price]) THEN 'Write Up' 
        ELSE 'As is' 
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
where  W.[Document No_]= 'S3001475'