SELECT TOP (1000) [timestamp]
      ,[Type]
      ,[No_]
      ,[Quantity]
      ,[Quantity (Base)]
      ,[Location Code]
      ,[Base Document Type]
      ,[Document Type]
      ,[Document No_]
      ,[Document Line No_]
      ,[Demand Date]
      ,[Percentage %]
      ,[Demand Qty_]
      ,[Demand No_]
      ,[Demand Hits]
      ,[Demand Location]
      ,[Modified by]
      ,[Modified at]
      ,[Entry No_]
      ,[Inventory on Demand Date]
      ,[Days too Late]
      ,[Rush Fee]
      ,[Order Value]
      ,[Fill Rate Calculated]
      ,[Customer No_]
      ,[Created at]
      ,[Qty_ on Hand]
      ,[Fill Percentage]
  FROM [Copyofproduction ].[dbo].[Production$Demand Line]



  --
  SELECT [No_],
  [Demand Location],
  --[Demand Date], 
  SUM([Demand Qty_]) AS Demand 
FROM [Production$Demand Line]
where 
--[No_] = 'CA6042689' and 
[Demand Date] between '01/01/2018' and '06/01/2024' 
--and [Demand Location] = '1'
Group by  [No_],[Demand Location]
--,[Demand Date]




---PROLIFT Inventory  SQL 

SELECT 
    Production$Location.Code AS Location,
    Production$Location.Name,
    Production$Location.[Responsibility Center] AS CSC,
    [Production$Item Ledger Entry$VSIFT$12].[Item No_],
    Production$Item.Description,
    Production$Item.[Unit Cost] AS UCost,
    ItemCat.[Description] AS ItemCategory,
    ItemCat.[Code] AS ICC,
    [Production$Item Ledger Entry$VSIFT$12].[SUM$Remaining Quantity] AS Inventory,
    [Production$Item Ledger Entry$VSIFT$12].[Unit of Measure Code],
    MAX([Production$Item Ledger Entry$VSIFT$1].[Posting Date]) AS [Last Posting Date],
    DATEDIFF(
        MONTH,
        MAX([Production$Item Ledger Entry$VSIFT$1].[Posting Date]),
        { fn NOW() }
    ) AS [Elapsed Months],
    (
        CASE [Entry Type]
            WHEN 0 THEN 'Purchase'
            WHEN 1 THEN 'Sale'
            WHEN 2 THEN 'Positive Adjmt.'
            WHEN 3 THEN 'Negative Adjmt.'
            WHEN 4 THEN 'Transfer'
            WHEN 5 THEN 'Consumption'
            WHEN 6 THEN 'Output'
            WHEN 7 THEN ''
            WHEN 8 THEN ''
            WHEN 9 THEN ''
            WHEN 10 THEN 'Work Order Usage'
            WHEN 11 THEN 'Project Work Order Usage'
            WHEN 12 THEN 'Conversion'
            WHEN 13 THEN 'Production'
            WHEN 14 THEN 'Return Order'
            ELSE ''
        END
    ) AS Type,
    (
        CASE [Location Type]
            WHEN 1 THEN 'Central'
            ELSE 'Van'
        END
    ) AS [Loc Type]
FROM 
    Production$Location
    INNER JOIN [Production$Item Ledger Entry$VSIFT$12] 
        ON Production$Location.Code = [Production$Item Ledger Entry$VSIFT$12].[Location Code]
    INNER JOIN Production$Item 
        ON [Production$Item Ledger Entry$VSIFT$12].[Item No_] = Production$Item.No_
    LEFT OUTER JOIN [Production$Item Ledger Entry$VSIFT$1] 
        ON [Production$Item Ledger Entry$VSIFT$12].[Item No_] = [Production$Item Ledger Entry$VSIFT$1].[Item No_]
        AND [Production$Item Ledger Entry$VSIFT$12].[Location Code] = [Production$Item Ledger Entry$VSIFT$1].[Location Code]
    INNER JOIN [Production$Item Category] ItemCat 
        ON Production$Item.[Item Category Code] = ItemCat.[Code]
WHERE 
    [Production$Item Ledger Entry$VSIFT$12].[Open] = 1 and [Production$Item Ledger Entry$VSIFT$12].[Item No_] = 'CA6042689'
GROUP BY 
    Production$Location.Code,
    Production$Location.Name,
    Production$Location.[Responsibility Center],
    [Production$Item Ledger Entry$VSIFT$12].[Item No_],
    Production$Item.Description,
    ItemCat.[Description],
    ItemCat.[Code],
    [Production$Item Ledger Entry$VSIFT$12].[Unit of Measure Code],
    Production$Item.[Unit Cost],
    [Production$Item Ledger Entry$VSIFT$12].[SUM$Remaining Quantity],
    [Production$Item Ledger Entry$VSIFT$12].[SUM$Remaining Quantity] * Production$Item.[Unit Cost],
    (
        CASE [Non-Returnable]
            WHEN 0 THEN ''
            ELSE 'Y'
        END
    ),
    (
        CASE [Entry Type]
            WHEN 0 THEN 'Purchase'
            WHEN 1 THEN 'Sale'
            WHEN 2 THEN 'Positive Adjmt.'
            WHEN 3 THEN 'Negative Adjmt.'
            WHEN 4 THEN 'Transfer'
            WHEN 5 THEN 'Consumption'
            WHEN 6 THEN 'Output'
            WHEN 7 THEN ''
            WHEN 8 THEN ''
            WHEN 9 THEN ''
            WHEN 10 THEN 'Work Order Usage'
            WHEN 11 THEN 'Project Work Order Usage'
            WHEN 12 THEN 'Conversion'
            WHEN 13 THEN 'Production'
            WHEN 14 THEN 'Return Order'
            ELSE ''
        END
    ),
    (
        CASE [Location Type]
            WHEN 1 THEN 'Central'
            ELSE 'Van'
        END
    )
HAVING 
    [Production$Item Ledger Entry$VSIFT$12].[SUM$Remaining Quantity] <> 0;




--- Table 1 --obsolete, demand, write off

SELECT 
    DL.[No_] AS Itemno,
    I.[Unit Cost],

    DL.[Demand Location],
   SUM(
        DL.[Demand Qty_]
        ) AS Demand_Qty,
    sum(
        DL.[Demand Hits]
        ) as deamndhit,
    MAX(
        DL.[Demand Date]
        ) AS [Last Demand Date],
   
    CASE 
        WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 12 THEN 'Yes'
        ELSE 'No'
    END AS Obsolete_Flag,
    CASE 
        WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 36 THEN 'Yes'
        ELSE 'No'
    END AS Write_Off_Flag
FROM 
    [Production$Demand Line] DL
LEFT JOIN Production$Item I
ON I.[No_] = DL.[No_] 

WHERE 
    DL.[Demand Date] >= '01/01/2018' 
    and DL.[No_] = 'CA6042689'
GROUP BY  
    DL.[No_],
    DL.[Demand Location],I.[Unit Cost];



-------Table 2--- Parts Inventory - item ledger entry

SELECT ILE.[Item No_], ILE.[Location Code],max(ILE.[Posting Date]) AS Posting_Date,
     
      sum(ILE.[Remaining Quantity]) as Remaining_Quantity
     
      ,ILE.[Demand Location],I.[Unit Cost], sum(I.[Unit Cost]*ILE.[Remaining Quantity]) as Inventory_Cost
      
  FROM [Copyofproduction ].[dbo].[Production$Item Ledger Entry] ILE
  left join Production$Item I ON I.[No_] = ILE.[Item No_] 
  WHERE 
  ILE.[Item No_] = 'CA6042689' and ILE.[Remaining Quantity] > 0

  group by ILE.[Item No_],ILE.[Location Code]
 
      ,ILE.[Demand Location],I.[Unit Cost]


-----Test Query ----------

--select [Unit Cost] from Production$Item where [No_] = 'CA6042689'

--select top 10 * from [Production$Demand Line]

--select * from Production$Item where [No_] = 'CA6042689' and 





----Final Combined query 

--- Table 1 --obsolete, demand, write off
WITH PartsLastDemand AS (
    SELECT 
        DL.[No_] AS ItemNo,
        I.[Unit Cost],
        DL.[Demand Location],
        SUM(DL.[Demand Qty_]) AS Demand_Qty,
        SUM(DL.[Demand Hits]) AS DemandHit,
        max(sku.[Reorder Point]) as ReorderPoint,
        CASE WHEN max(sku.[Reorder Point])>0 THEN 'Yes' else 'No' end as Reorderflag,
        MAX(DL.[Demand Date]) AS [Last Demand Date],
        CASE 
            WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 12 THEN 'Yes'
            ELSE 'No'
        END AS Obsolete_Flag,
        CASE 
            WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 36 THEN 'Yes'
            ELSE 'No'
        END AS Write_Off_Flag
    FROM 
        [Production$Demand Line] DL
    LEFT JOIN 
        Production$Item I ON I.[No_] = DL.[No_] 
    left Join [Production$Stockkeeping Unit] sku
     on DL.[Demand Location] = sku.[Location Code] and  DL.[No_] = sku.[Item No_]
    WHERE 
        DL.[Demand Date] >= '01/01/2018'
        AND DL.[No_] = 'TY64130U361071'
    GROUP BY  
        DL.[No_],
        DL.[Demand Location],
        I.[Unit Cost],sku.[Reorder Point]
),

PartsInventory AS (
    SELECT 
        ILE.[Item No_],
        ILE.[Location Code],
        ILE.[Entry Type],
      /**  CASE ILE.[Entry Type]
    WHEN 0 THEN 'Purchase'
    WHEN 1 THEN 'Sale'
    WHEN 2 THEN 'Positive Adjmt.'
    WHEN 3 THEN 'Negative Adjmt.'
    WHEN 4 THEN 'Transfer'
    WHEN 5 THEN 'Consumption'
    WHEN 6 THEN 'Output'
    WHEN 7 THEN 'Work Order Usage'
    WHEN 8 THEN 'Project Work Order Usage'
    WHEN 9 THEN 'Conversion'
    WHEN 10 THEN 'Production'
    WHEN 11 THEN 'Return Order'
    ELSE 'Other'
END AS EntryTypeName, **/
--MAX(CASE WHEN [Entry Type] = 0 THEN [Posting Date] END) AS Purchase,
    --MAX(CASE WHEN [Entry Type] = 1 THEN [Posting Date] END) AS Sale,
    --MAX(CASE WHEN [Entry Type] = 2 THEN [Posting Date] END) AS [Positive Adjmt.],
    --MAX(CASE WHEN [Entry Type] = 3 THEN [Posting Date] END) AS [Negative Adjmt.],
    --MAX(CASE WHEN [Entry Type] = 4 THEN [Posting Date] END) AS Transfer,
    
    --MAX(CASE WHEN [Entry Type] = 6 THEN [Posting Date] END) AS [Work Order Usage],
    --MAX(CASE WHEN [Entry Type] = 7 THEN [Posting Date] END) AS [Project Work Order Usage],
    
    --MAX(CASE WHEN [Entry Type] = 10 THEN [Posting Date] END) AS [Return Order],
        --MAX(ILE.[Posting Date]) AS Posting_Date,
        SUM(ILE.[Remaining Quantity]) AS Remaining_Quantity,
        ILE.[Demand Location],
        max(sku.[Reorder Point]) as ReorderPoint,
        CASE WHEN max(sku.[Reorder Point])>0 THEN 'Yes' else 'No' end as Reorderflag,
        I.[Unit Cost],
        SUM(I.[Unit Cost] * ILE.[Remaining Quantity]) AS Inventory_Cost
    FROM 
        [Copyofproduction].[dbo].[Production$Item Ledger Entry] ILE
    LEFT JOIN 
        Production$Item I ON I.[No_] = ILE.[Item No_] 
    left join [Production$Stockkeeping Unit] sku
     on ILE.[Demand Location] = sku.[Location Code] and  ILE.[Item No_] = sku.[Item No_]
    WHERE 
        ILE.[Item No_] = 'CA6033487'
        AND ILE.[Remaining Quantity] > 0
    GROUP BY 
        ILE.[Item No_],
        ILE.[Location Code],
        ILE.[Demand Location],
        I.[Unit Cost],sku.[Reorder Point],
         ILE.[Entry Type]
)

SELECT 
    -- All columns from PartsLastDemand
    PLD.ItemNo,
    PLD.[Unit Cost] AS Demand_Unit_Cost,
    PLD.[Demand Location],
    PLD.Demand_Qty,
    PLD.DemandHit,
    PLD.[Last Demand Date],
    PLD.Obsolete_Flag,
    PLD.Write_Off_Flag,

    -- All columns from PartsInventory
    PI.[Item No_],
    PI.[Location Code],
    PI.Posting_Date,
    PI.Remaining_Quantity,
    PI.[Demand Location] AS Inventory_Demand_Location,
    PI.[Unit Cost] AS Inventory_Unit_Cost,
    PI.Inventory_Cost

FROM 
    PartsLastDemand PLD
FULL OUTER JOIN 
    PartsInventory PI
    ON PLD.ItemNo = PI.[Item No_]
    AND PLD.[Demand Location] = PI.[Location Code];



---PBI Updated Parts Obsolete 

SELECT 
        DL.[No_] AS ItemNo,
        I.[Unit Cost],
        I.[Description],
        DL.[Demand Location],
        --DL.[Location Code],
        SUM(DL.[Demand Qty_]) AS Demand_Qty,
        SUM(DL.[Demand Hits]) AS DemandHit,
        max(sku.[Reorder Point]) as ReorderPoint,
        CASE WHEN max(sku.[Reorder Point])>0 THEN 'Yes' else 'No' end as Reorderflag,
        MAX(DL.[Demand Date]) AS [Last Demand Date],
       CASE 
    WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 36 THEN 'Obsolete WriteOff'
    WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 24 THEN 'Obsolete Last 24-36M'
    WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 18 THEN 'Obsolete Last 18-24M'
    WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 15 THEN 'Obsolete Last 15-18M'
    WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 12 THEN 'Obsolete Last 12-15M'
     WHEN DATEDIFF(DAY, MAX(DL.[Demand Date]), GETDATE()) < 0 THEN 'Demand Date Issue'
     when SUM(DL.[Demand Qty_]) <= 0 then 'Not in use since purchase'
    ELSE 'Not Obsolete last 12M'
END 
AS Obsolete_Flag,
        CASE 
            WHEN DATEDIFF(MONTH, MAX(DL.[Demand Date]), GETDATE()) > 36 THEN 'Yes'
            ELSE 'No'
        END AS Write_Off_Flag
    FROM 
        [Production$Demand Line] DL
    LEFT JOIN 
        Production$Item I ON I.[No_] = DL.[No_] 
    left Join [Production$Stockkeeping Unit] sku
     on DL.[Demand Location] = sku.[Location Code] and  DL.[No_] = sku.[Item No_]
    --WHERE 
        --DL.[Demand Date] >= '01/01/2018'
        --DL.[No_] = 'CA6042689'
    GROUP BY  
        DL.[No_],
        DL.[Demand Location],
        --DL.[Location Code],
        I.[Unit Cost],sku.[Reorder Point], I.[Description]



--TEST 

        select TOP 10 * from  [Production$Item Ledger Entry] 
        -- where   [Item No_] ='TY326701262071'

-- tEST ITEM LEDGER ENTRY 

SELECT 
        ILE.[Item No_],
        ILE.[Location Code],IC.[Code],IC.[Description],
        MAX(ILE.[Posting Date]) AS [Last Posting Date],
        -- Calculate Last Purchase Date for this item only
    (SELECT MAX([Posting Date]) 
     FROM [Copyofproduction].[dbo].[Production$Item Ledger Entry] ILE2
     WHERE ILE2.[Item No_] = ILE.[Item No_] AND ILE2.[Entry Type] = 0
    ) AS Last_Purchase_Date,
        SUM(ILE.[Remaining Quantity]) AS Remaining_Quantity,
        ILE.[Demand Location],
        --max(sku.[Reorder Point]) as ReorderPoint,
        --CASE WHEN max(sku.[Reorder Point])>0 THEN 'Yes' else 'No' end as Reorderflag,
        I.[Unit Cost],
         I.[Description],
         CASE 
        WHEN LEN(ILE.[Location Code]) <= 2 THEN 'Central'
        ELSE 'Van'
    END AS LocationType,
        SUM(I.[Unit Cost] * ILE.[Remaining Quantity]) AS Inventory_Cost
    FROM 
        [Copyofproduction].[dbo].[Production$Item Ledger Entry] ILE
    LEFT JOIN 
        Production$Item I ON I.[No_] = ILE.[Item No_] 
    left join [Production$Item Category] IC
     on I.[Item Category Code] = IC.[Code] 
    WHERE 
       ILE.[Item No_] = 'NP8100' 
       --and ILE.[Entry Type] = 0  
    GROUP BY 
        ILE.[Item No_],
        ILE.[Location Code],
        ILE.[Demand Location],
        I.[Unit Cost],IC.[Code],IC.[Description], I.[Description],ILE.[Entry Type]
having sum(ILE.[Remaining Quantity]) > 0


---test 
select top 100 * from [Production$Stockkeeping Unit]

--

---test 
select   ILE.[Item No_],
        ILE.[Location Code], SUM(ILE.[Remaining Quantity]) AS Remaining_Quantit from [Production$Item Ledger Entry] ILE where 
--[Entry Type] = 0 and 
[Item No_] = 'NP8100' 
GROUP BY ILE.[Item No_],
        ILE.[Location Code]
----
-- SKU QUERY 

SELECT 
    SKU.[Location Code], 
    SKU.[Item No_], 
    SKU.[Fixed Bin], 
    SKU.[Reorder Point], 
    SKU.[Reorder Quantity], 
    SKU.[Vendor No_] ,
     I.[Vendor No_] AS [Item Vendor No_],
    CASE 
        WHEN SKU.[Vendor No_] IS NULL THEN V_I.[Name]
        WHEN I.[Vendor No_] IS NULL THEN V_SKU.[Name]
        WHEN SKU.[Vendor No_] <> I.[Vendor No_] THEN CONCAT(V_SKU.[Name], ' / ', V_I.[Name])
        ELSE V_SKU.[Name]
    END AS [Vendor Names]
FROM 
    [Production$Stockkeeping Unit] AS SKU
LEFT JOIN [Production$Item] AS I 
ON SKU.[Item No_] = I.[No_]
LEFT JOIN [Production$Vendor] AS V_SKU 
ON SKU.[Vendor No_] = V_SKU.[No_]
LEFT JOIN [Production$Vendor] AS V_I 
ON I.[Vendor No_] = V_I.[No_]

WHERE 
SKU.[Item No_] = 'CA6042689'





---test 
Select  TOP 1000 * from Production$Item where [Manufacturer Code] like '%TAYLOR%'
FROM 
        [Copyofproduction].[dbo].[Production$Item Ledger Entry] ILE
    LEFT JOIN 
        Production$Item I ON I.[No_] = ILE.[Item No_] 
    left join [Production$Stockkeeping Unit] sku
     on ILE.[Demand Location] = sku.[Location Code] and  ILE.[Item No_] = sku.[Item No_]