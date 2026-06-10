---SQL NEW FOR GL Budget with CSC,PC 

SELECT 
    b.[G_L Account No_],
    b.[Date], 
    b.[Global Dimension 1 Code] AS CSC,
    csc.[Name] as CSC_Name,
    b.[Global Dimension 2 Code] AS [PC Code],
    pc.[Name] AS [Profit Center] , 
    SUM(-b.[Amount]) AS Budget
FROM 
    [Copyofproduction].[dbo].[Production$G_L Budget Entry] b
left join [Production$Dimension Value] pc
on pc.[Code]=b.[Global Dimension 2 Code]  and pc.[Dimension Code] = 'PROFIT CENTER'
left join [Production$Dimension Value] csc
on csc.[Code]=b.[Global Dimension 1 Code] and csc.[Dimension Code] = 'BRANCH'
WHERE 
    [Budget Name] = 'CURRENT' 
    AND [Date] between '07/01/2025' and '07/31/2025' 
    AND [G_L Account No_] = '40002'
   
GROUP BY 
    [G_L Account No_], 
    [Date], 
    [Global Dimension 1 Code], 
    [Global Dimension 2 Code],pc.[Name],csc.[Name];



--- SQL NEW FOR GL ACTUAL with CSC,PC 
SELECT 
    a.[G_L Account No_], 
    CAST(a.[Posting Date] AS DATE) AS [Posting Date], 
    a.[Global Dimension 1 Code] AS CSC, 
    csc.[Name] as CSC_Name,
    a.[Global Dimension 2 Code] AS [Profit Center],
    pc.[Name] AS [Profit Center] ,  
    SUM(-a.[Amount]) AS Actual
FROM 
    [Copyofproduction].[dbo].[Production$G_L Entry] a
left join [Production$Dimension Value] pc
on pc.[Code]=a.[Global Dimension 2 Code]  and pc.[Dimension Code] = 'PROFIT CENTER'
left join [Production$Dimension Value] csc
on csc.[Code]=a.[Global Dimension 1 Code] and csc.[Dimension Code] = 'BRANCH'
WHERE 
    --a.[Budget Name] = 'CURRENT' 
     a.[Posting Date] between '07/01/2025' and '07/31/2025'
     --and '05/31/2025' 
    AND a.[G_L Account No_] = '40002'
GROUP BY 
    [G_L Account No_], 
    [Posting Date], 
    [Global Dimension 1 Code], 
    [Global Dimension 2 Code],pc.[Name],csc.[Name];



--test 45007
Select distinct   a.[G_L Account No_]

FROM 
    [Copyofproduction].[dbo].[Production$G_L Entry] a
left join [Production$Dimension Value] pc
on pc.[Code]=a.[Global Dimension 2 Code]  and pc.[Dimension Code] = 'PROFIT CENTER'
left join [Production$Dimension Value] csc
on csc.[Code]=a.[Global Dimension 1 Code] and csc.[Dimension Code] = 'BRANCH'

--


----- GL DASHBOARD FIXES
      with GL_Actual AS 
      (select [G_L Account No_], SUM([Amount]) as Actual
  FROM [Copyofproduction ].[dbo].[Production$G_L Entry]

where 
[G_L Account No_] = '40002' and 
([Posting Date] between '07/01/2025' and '07/31/2025')
group by [G_L Account No_]),

------
GL_Budget as 
(
SELECT [G_L Account No_], SUM([Amount]) AS Budget
  FROM [Copyofproduction ].[dbo].[Production$G_L Budget Entry]

  where 
  --[G_L Account No_] = '45007' and 
   [Budget Name] = 'CURRENT' 
 and ([Date] between '07/01/2025' and '07/31/2025')
group by [G_L Account No_]

)

select  COALESCE(B.[G_L Account No_],A.[G_L Account No_]) as [G_L Account No_],
    sl.[Description],
    ISNULL(-A.Actual, 0) AS Actual,
    ISNULL(-B.Budget, 0) AS Budget,
    ISNULL(-A.Actual, 0) - ISNULL(-B.Budget, 0) AS Variance,
    CASE 
        WHEN ISNULL(B.Budget, 0) = 0 THEN 0 
        ELSE (ISNULL(A.Actual, 0) - ISNULL(B.Budget, 0)) / ISNULL(B.Budget, 0)
    END AS [Variance%]
      from GL_Actual as A 
full outer JOIN GL_Budget B
ON A.[G_L Account No_] =B.[G_L Account No_]
left join [Production$Acc_ Schedule Line] sl
on COALESCE(B.[G_L Account No_],A.[G_L Account No_])= sl.[Row No_]
where 
--COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '5%' and 
sl.[Schedule Name] = 'Z_ P&L' 

ORDER BY COALESCE(B.[G_L Account No_],A.[G_L Account No_])



--- flagging the GL's 


----- flagging 

WITH GL_Actual AS (
    SELECT [G_L Account No_],CAST([Posting Date] AS DATE) AS [Posting Date] , SUM([Amount]) AS Actual
    FROM [Copyofproduction].[dbo].[Production$G_L Entry]
    WHERE [Posting Date] > '2024-01-01' 
    and [G_L Account No_] ='46060'
    GROUP BY [G_L Account No_],[Posting Date]
),
GL_Budget AS (
    SELECT [G_L Account No_],[Date], sum([Amount]) AS Budget
    FROM [Copyofproduction].[dbo].[Production$G_L Budget Entry]
    WHERE [Budget Name] = 'CURRENT' 
      AND [Date] > '2024-01-01' 
      --and [G_L Account No_] ='46060'
    GROUP BY [G_L Account No_],[Date]
)

SELECT 
    sl.[Row No_] AS [G_L Account No_],
    sl.[Description],
    A.[Posting Date],
    B.[Date],
    ISNULL(-A.Actual, 0) AS Actual,
    ISNULL(-B.Budget, 0) AS Budget,
    ISNULL(-A.Actual, 0) - ISNULL(-B.Budget, 0) AS Variance,
    CASE 
        WHEN ISNULL(B.Budget, 0) = 0 THEN 0
        ELSE (ISNULL(-A.Actual, 0) - ISNULL(-B.Budget, 0)) / ISNULL(-B.Budget, 0)
    END AS [Variance%]
    
   /** -- 🔖 GL Category Flag based on Row No_ and Description / gl with null actuals and budget are uncategorized
    CASE
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '4%' THEN 'Sales/Revenue'
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '5%' THEN 'Cost of Sales'
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '61%' THEN 'Operating Expenses/Personnel Expenses'
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '62%' THEN 'Occupancy'
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '64%' THEN 'Selling Expenses'
        WHEN sl.[Description] LIKE '65%' THEN 'General and Administrative'
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '66%' THEN 'Misc Operating Expense'
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '70%' THEN 'Other Income'
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '71%' OR sl.[Row No_] LIKE '652%' THEN 'Other Expenses'
        WHEN COALESCE(B.[G_L Account No_],A.[G_L Account No_]) LIKE '8%' THEN 'Income Taxes'
        ELSE 'Uncategorized'
    END AS GL_Category_Flag
    **/

FROM [Copyofproduction].[dbo].[Production$Acc_ Schedule Line] sl
LEFT JOIN GL_Actual A ON sl.[Row No_] = A.[G_L Account No_]
LEFT JOIN GL_Budget B ON sl.[Row No_] = B.[G_L Account No_]
WHERE 
--sl.[Row No_] LIKE '4%' OR sl.[Row No_] LIKE '5%' OR sl.[Row No_] LIKE '6%' OR sl.[Row No_] LIKE '7%' OR sl.[Row No_] LIKE '8%'AND 
sl.[Schedule Name] = 'Z_ P&L'
ORDER BY sl.[Row No_]




---TEST


SELECT  *
-- [G_L Account No_], SUM([Amount]) AS Budget
  --FROM [Production$G_L Entry]
FROM [Copyofproduction ].[dbo].[Production$G_L Budget Entry]
  where 
  [G_L Account No_] = '40007' and 
   [Budget Name] = '26P1V1' 
 --[Posting Date] > '01/01/2024'
--group by [G_L Account No_]


select  [Row No_] as [GL Account],[Description]
FROM [Copyofproduction].[dbo].[Production$Acc_ Schedule Line]

where [Schedule Name] = 'Z_ P&L' and [Row No_] <> ''


---
SELECT 
    CASE 
        WHEN TRY_CAST([Row No_] AS INT) BETWEEN 1 AND 15 
            THEN LEFT([Description], CHARINDEX(' -', [Description]) - 1)
        ELSE [Row No_]
    END AS [GL Account],
    [Description]
FROM 
    [Copyofproduction].[dbo].[Production$Acc_ Schedule Line]
WHERE 
    [Schedule Name] = 'Z_ P&L' 
    AND [Row No_] <> ''

---

SELECT [G_L Account No_], SUM([Amount]) AS Budget
  FROM [Copyofproduction ].[dbo].[Production$G_L Budget Entry]

  where 
  [G_L Account No_] = '45015' and 
   [Budget Name] = 'CURRENT' 
 and ([Date] between '12/01/2025' and '12/31/2025')
group by [G_L Account No_]
---

-----------GL mAINTENACE gp SPLIT GOLD, SILVER , PLATINUM

SELECT gl.[G_L Account No_],mch.[Contract Type],
--CAST([Posting Date] AS DATE) AS [Posting Date] ,
SUM(gl.[Amount]) AS Actual
    FROM [Copyofproduction].[dbo].[Production$G_L Entry] gl
    LEFT JOIN [Production$Maintenance Contract Header] mch 
    on mch.[No_]=gl.[ELC Document No_]
    WHERE gl.[Posting Date] BETWEEN '12/01/2025' AND '12/31/2025' 
    and gl.[G_L Account No_] in ('43030','53030','53020')
    GROUP BY gl.[G_L Account No_],mch.[Contract Type]
    --,[Posting Date]

-----