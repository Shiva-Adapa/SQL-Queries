SELECT 
    mch.[Responsibility Center],
    mch.[Sell-to Customer No_],
    mch.[Sell-to Customer Name],
    mch.[Sell-to Address],
    mch.[No_],
    mch.[Document Status],
    mch.[Cancel Reason Code],
    mch.[Contract Type],
    CASE 
        WHEN mch.[Contract Type] IN ('BRONZE', 'SILVER') THEN 'PM'
        WHEN mch.[Contract Type] IN ('GOLD', 'PLATINUM') THEN 'GM'
        WHEN mch.[Contract Type] = 'T360' THEN 'T360'
        ELSE 'OTHER'
    END AS [PM/GM Flag],
    mch.[Default Service Type],
    mcl.[Equipment Object],
    mcl.[Description],
    mcl.[Status],
    CASE 
    WHEN mcl.[Status] = 0 THEN 'Open'
    WHEN mcl.[Status] = 1 THEN 'Released'
    WHEN mcl.[Status] = 2 THEN 'Closed'
    WHEN mcl.[Status] = 3 THEN 'Cancelled'
    else 'Other' end as [MCL Status Flag],

    mcl.[Annual Amount] AS [MCL Annual Amount],
    mch.[Total Annual Amount] AS [MCH Annual Amount],
    mcl.[Contract Hours_Year],
    CAST(mcl.[Starting Date] AS DATE) AS [MCL Starting Date],
    CAST(mcl.[Finishing Date] AS DATE) AS [MCL Finishing Date],
    CAST(mch.[Order Date] AS DATE) AS [MCH Order Date],
    CAST(mch.[Posting Date] AS DATE) AS [MCH Posting Date],
    CAST(mch.[Starting Date] AS DATE) AS [MCH Starting Date],
    CAST(mch.[Finishing Date] AS DATE) AS [MCH Finishing Date],
    CAST(mch.[Creation Datetime] AS DATE) AS [MCH Creation Date]
FROM 
    [Production$Maintenance Contract Header] mch
LEFT JOIN 
    [Production$Maintenance Contract Line] mcl
    ON mch.[No_] = mcl.[Document No_]
    AND mch.[Sell-to Customer No_] = mcl.[Customer]
WHERE 
    mch.[Document Type] = 1 
    AND CAST(mch.[Starting Date] AS DATE) > '2015-01-01'
    and mcl.[Status] in ('1','2','3') --released/closed/cancelled
    --and mch.[No_] = 'MC008657'
    and mch.[Starting Date] > mcl.[Starting Date];





-- Lost contracts


-- CTE to get cancelled contract line entries
WITH cancelled_date AS (
    SELECT  
        DATEADD(HOUR, -5, cle.[Date and Time]) AS [Date and Time],
        cle.[Primary Key Field 2 Value] AS [Maintenance Contract],
        mcl.[Equipment Object],
        cle.[Primary Key Field 3 Value] AS [Line No:]
    FROM  
        [Production$Maintenance Contract Line] mcl
    LEFT JOIN  
        [Production$Change Log Entry] cle
        ON mcl.[Document No_] = cle.[Primary Key Field 2 Value]
        AND CAST(REPLACE(mcl.[Line], ',', '') AS DECIMAL(18,2)) = 
            CAST(REPLACE(cle.[Primary Key Field 3 Value], ',', '') AS DECIMAL(18,2))
    WHERE  
        cle.[Table No_] = '11021579'  -- MC Line
        AND cle.[Field No_] = '95'    -- Status
        AND cle.[New Value] = 'Cancelled'
        --and mcl.[Document No_] = 'MC008657'
)

-- Main SELECT query
SELECT  
    H.[Responsibility Center] AS [CSC],
    L.[Document No_],
    H.[Contract Type],
    H.[Sell-to Customer Name] AS [Customer Name],
    L.[Equipment Object],
    EO.[Manufacturer Code] AS [Make],
    L.[Equipment Model],
    L.[Object Serial No_] AS [Serial Number],
    MAX(CAST(cd.[Date and Time] AS DATE)) AS [Cancelled Date],
    CAST(H.[Starting Date] AS DATE) AS [Header_Starting_Date],
    CAST(H.[Finishing Date] AS DATE) AS [Header_Finishing_Date],
    CAST(L.[Starting Date] AS DATE) AS [Line_Starting_Date],
    CAST(L.[Finishing Date] AS DATE) AS [Line_Finishing_Date],
    sp.[Name] AS [Sales Person],
    L.[Reason for Cancellation] AS [Reason Code],
    H.[Cancel Reason Code] AS [Header_Cancel_Reason_Code],

    -- Determine Object Status
    CASE
        WHEN H.[Finishing Date] >= L.[Finishing Date] AND L.[Status] = 3 THEN 'Cancelled'
        ELSE 'Other'
    END AS [Object_Status],

    -- Determine Contract Status
    CASE
        WHEN H.[Status] = 3 THEN 'Cancelled'
        ELSE 'Other'
    END AS [Contract_Status],

    L.[Status] AS [Line_Status],
    H.[Status] AS [Header_Status]

FROM  
    [Production$Maintenance Contract Line] AS L
LEFT JOIN  
    [Production$Maintenance Contract Header] AS H 
    ON L.[Document No_] = H.[No_]
LEFT JOIN  
    [Production$Customer] c 
    ON c.[No_] = H.[Sell-to Customer No_]
LEFT JOIN  
    [Production$Salesperson_Purchaser] sp 
    ON sp.Code = c.[Salesperson Service]
LEFT JOIN  
    [Production$Equipment Object] EO 
    ON L.[Equipment Object] = EO.[No_]
LEFT JOIN  
    cancelled_date cd 
    ON cd.[Maintenance Contract] = L.[Document No_] 
    AND cd.[Equipment Object] = L.[Equipment Object]

WHERE  
    L.[Starting Date] >= H.[Starting Date]
    AND L.[Finishing Date] <= H.[Finishing Date]
    AND
     L.[Status] = 3  -- Only cancelled lines
    and H.[No_] = 'MC019957'
GROUP BY  
    L.[Equipment Object],
    H.[Responsibility Center],
    L.[Document No_],
    H.[Contract Type],
    H.[Sell-to Customer Name],
    EO.[Manufacturer Code],
    L.[Equipment Model],
    L.[Object Serial No_],
    H.[Starting Date],
    H.[Finishing Date],
    L.[Starting Date],
    L.[Finishing Date],
    sp.[Name],
    L.[Reason for Cancellation],
    H.[Cancel Reason Code],
    L.[Status],
    H.[Status]

ORDER BY  
    L.[Document No_];



--test 

select top 1000 * from  [Production$Change Log Entry] 
where [Primary Key Field 2 Value]= 'MC019957' and
[Table No_] = '11021579'  -- MC Line
        --AND [Field No_] = '95'    -- Status
       -- AND [New Value] = 'Cancelled'


---------------------------------------------xxxxxxxxxxcontract year mapxxxxxxxxxxxxxxxxxx-----------------------

-- Step 1: Create a list of contract-year mappings
WITH ContractDates AS (
    SELECT 
        mch.[No_] AS ContractNo,
        YEAR(mch.[Starting Date]) AS StartYear,
        YEAR(mch.[Finishing Date]) AS EndYear
    FROM 
        [Production$Maintenance Contract Header] mch
    WHERE 
        mch.[Document Type] = 1  -- order
        and mcl.[Status] in ('1','2','3') --released/closed/cancelled
        AND mch.[Starting Date] > '2015-01-01'
),
-- Step 2: Generate years using a tally table (0 to 20 years for contract span)
YearsCTE AS (
    SELECT TOP 20 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS YearOffset
    FROM sys.all_objects
),
ContractYearMap AS (
    SELECT 
        cd.ContractNo,
        cd.StartYear + y.YearOffset AS ActiveYear
    FROM 
        ContractDates cd
    JOIN 
        YearsCTE y ON cd.StartYear + y.YearOffset <= cd.EndYear
),
-- Step 3: Count distinct contracts per year
YearlyContractCounts AS (
    SELECT 
        ActiveYear AS [Year],
        COUNT(DISTINCT ContractNo) AS ActiveContracts
    FROM 
        ContractYearMap
    GROUP BY 
        ActiveYear
),
-- Step 4: Calculate % change YoY
FinalOutput AS (
    SELECT 
        [Year],
        ActiveContracts,
        LAG(ActiveContracts) OVER (ORDER BY [Year]) AS PrevYearContracts,
        CAST(ROUND(
            (1.0 * (ActiveContracts - LAG(ActiveContracts) OVER (ORDER BY [Year])) / 
            NULLIF(LAG(ActiveContracts) OVER (ORDER BY [Year]), 0)) * 100, 2
        ) AS DECIMAL(6,2)) AS YoY_Percent_Change
    FROM 
        YearlyContractCounts
)
SELECT * FROM FinalOutput
ORDER BY [Year];





-----pm/gm/t360 division

-- Step 1: Create a list of contract-year mappings with PM/GM/T360 flag
-- Step 1: Classify contracts and get year range
-- Step 1: Classify contracts and get year range
WITH ContractDates AS (
    SELECT 
        mch.[No_] AS ContractNo,
        YEAR(mch.[Starting Date]) AS StartYear,
        YEAR(mch.[Finishing Date]) AS EndYear,
        CASE 
            WHEN mch.[Contract Type] IN ('BRONZE', 'SILVER') THEN 'PM'
            WHEN mch.[Contract Type] IN ('GOLD', 'PLATINUM') THEN 'GM'
            WHEN mch.[Contract Type] = 'T360' THEN 'T360'
            ELSE 'OTHER'
        END AS ContractFlag
    FROM 
        [Production$Maintenance Contract Header] mch
        LEFT JOIN 
    [Production$Maintenance Contract Line] mcl
    ON mch.[No_] = mcl.[Document No_]
    AND mch.[Sell-to Customer No_] = mcl.[Customer]
    WHERE 
         mch.[Document Type] = 1  -- order
        and mcl.[Status] in ('1','2','3') --released/closed/cancelled
        AND mch.[Starting Date] > '2015-01-01'
),
-- Step 2: Generate year spans (up to 20 years)
YearsCTE AS (
    SELECT TOP 20 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS YearOffset
    FROM sys.all_objects
),
-- Step 3: Expand contracts across each active year
ContractYearMap AS (
    SELECT 
        cd.ContractNo,
        cd.ContractFlag,
        cd.StartYear + y.YearOffset AS ActiveYear
    FROM 
        ContractDates cd
    JOIN 
        YearsCTE y 
        ON cd.StartYear + y.YearOffset <= cd.EndYear
),
-- Step 4: Count distinct contracts by year and classification
YearlyMatrix AS (
    SELECT 
        ActiveYear AS [Year],
        ContractFlag,
        COUNT(DISTINCT ContractNo) AS ContractCount
    FROM 
        ContractYearMap
    GROUP BY 
        ActiveYear,
        ContractFlag
)
-- Step 5: Pivot to final matrix with Total column
SELECT
    [Year],
    ISNULL(SUM(CASE WHEN ContractFlag = 'PM' THEN ContractCount END), 0) AS PM,
    ISNULL(SUM(CASE WHEN ContractFlag = 'GM' THEN ContractCount END), 0) AS GM,
    ISNULL(SUM(CASE WHEN ContractFlag = 'T360' THEN ContractCount END), 0) AS T360,
    ISNULL(SUM(CASE WHEN ContractFlag = 'OTHER' THEN ContractCount END), 0) AS OTHER,
    -- Total column
    ISNULL(SUM(ContractCount), 0) AS Total
FROM 
    YearlyMatrix
GROUP BY 
    [Year]
ORDER BY 
    [Year];



--- CSC WISE CONTRACTS COUNT 
WITH CalendarYears AS (
    SELECT DISTINCT YEAR([Starting Date]) AS Year
    FROM [dbo].[Maintenance Contract]
),
YearEndContracts AS (
    SELECT
        cy.Year,
        mc.[Responsibility Center],

        COUNT(CASE 
            WHEN mc.[Contract Type] IN ('BRONZE', 'SILVER') THEN 1
        END) AS PM,

        COUNT(CASE 
            WHEN mc.[Contract Type] IN ('GOLD', 'PLATINUM') THEN 1
        END) AS GM,

        COUNT(CASE 
            WHEN mc.[Contract Type] = 'T360' THEN 1
        END) AS T360,

        COUNT(CASE 
            WHEN mc.[Contract Type] NOT IN ('BRONZE', 'SILVER', 'GOLD', 'PLATINUM', 'T360') THEN 1
        END) AS OTHER,

        COUNT(*) AS Total

    FROM CalendarYears cy
    JOIN [dbo].[Maintenance Contract] mc
        ON mc.[Starting Date] <= DATEFROMPARTS(cy.Year, 12, 31)
       AND mc.[Ending Date] >= DATEFROMPARTS(cy.Year, 1, 1)
    GROUP BY
        cy.Year,
        mc.[Responsibility Center]
)
SELECT *
FROM YearEndContracts
ORDER BY Year, [Responsibility Center];
