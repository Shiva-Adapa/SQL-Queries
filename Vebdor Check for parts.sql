SELECT 
      i.[No_] as ItemNo
      ,i.[Description]
      ,v.[No_] as VendorNo 
      ,v.[Name] as VendorName
      ,i.[Vendor Item No_]
      ,i.[Manufacturer Code]
      ,i.[Item Category Code]
  FROM [Copyofproduction ].[dbo].[Production$Item] i
  left join [Production$Vendor] v on i.[Vendor No_] = v.[No_]
  where i.[Vendor No_] in ('116998', '99116998', 'V2793', 'V3210', 'V0676', '13540', '9913540', 'V3674', '99V0430', 'V0430')
  

--vendor Cummins/ sudden service items on item card
SELECT 
     v.[No_] as VendorNo 
      ,v.[Name] as VendorName
      ,i.[Vendor Item No_]
      ,i.[No_] as ItemNo
      ,i.[Description]
      ,i.[Manufacturer Code]
      ,i.[Item Category Code]
       ,v.[Address]
      ,v.[Address 2]
      ,v.[City]
   
      ,v.[Phone No_]
            ,v.[Blocked]
FROM [Production$Vendor] v
  left join [Production$Item] i on i.[Vendor No_] = v.[No_]
  where v.[No_] in ('116998', '99116998', 'V2793', 'V3210', 'V0676', '13540', '9913540', 'V3674', '99V0430', 'V0430')


  -- Item Inventory Locattion

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
    DATEDIFF(MONTH, MAX([Production$Item Ledger Entry$VSIFT$1].[Posting Date]), { fn NOW() }) AS [Elapsed Months],
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
    END AS Type,
    CASE [Location Type]
        WHEN 1 THEN 'Central'
        ELSE 'Van'
    END AS [Loc Type]
FROM 
    Production$Location
INNER JOIN 
    [Production$Item Ledger Entry$VSIFT$12] 
ON 
    Production$Location.Code = [Production$Item Ledger Entry$VSIFT$12].[Location Code]
INNER JOIN 
    Production$Item 
ON 
    [Production$Item Ledger Entry$VSIFT$12].[Item No_] = Production$Item.No_
LEFT OUTER JOIN 
    [Production$Item Ledger Entry$VSIFT$1] 
ON 
    [Production$Item Ledger Entry$VSIFT$12].[Item No_] = [Production$Item Ledger Entry$VSIFT$1].[Item No_]
    AND [Production$Item Ledger Entry$VSIFT$12].[Location Code] = [Production$Item Ledger Entry$VSIFT$1].[Location Code]
INNER JOIN 
    [Production$Item Category] ItemCat 
ON 
    Production$Item.[Item Category Code] = ItemCat.[Code]  -- Added join for Item Category
WHERE 
    [Production$Item Ledger Entry$VSIFT$12].[Open] = 1
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
    CASE [Non-Returnable]
        WHEN 0 THEN ''
        ELSE 'Y'
    END,
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
    END,
    CASE [Location Type]
        WHEN 1 THEN 'Central'
        ELSE 'Van'
    END
HAVING 
    [Production$Item Ledger Entry$VSIFT$12].[SUM$Remaining Quantity] <> 0;


-- stock keeping unit 

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
where 
--I.[Vendor No_] in ('116998', '99116998', 'V2793', 'V3210', 'V0676', '13540', '9913540', 'V3674', '99V0430', 'V0430')
SKU.[Item No_] in ('NPCE2897331D', 'NPCE3058653', 'NPCE3978072', 'NPCE4010519', 'NPCE4384356', 'NPCE4928594RX', 'NPCE4932615', 'NPCE4992509', 'NPCE5253019', 'NPCE5263194D', 'NPCE5301294', 'NPCE5402022', 'NPCE5473296RX', 'NPCE5566893')




--STOCK KEEPING UNIT CHECK FOR VENDORS
SELECT
SKU.[Location Code], 
    SKU.[Item No_], 
    SKU.[Fixed Bin], 
    SKU.[Reorder Point], 
    SKU.[Reorder Quantity], 
    SKU.[Vendor No_] 
FROM 
    [Production$Stockkeeping Unit] SKU
    WHERE SKU.[Item No_] in ('NPCE2897331D', 'NPCE3058653', 'NPCE3978072', 'NPCE4010519', 'NPCE4384356', 'NPCE4928594RX', 'NPCE4932615', 'NPCE4992509', 'NPCE5253019', 'NPCE5263194D', 'NPCE5301294', 'NPCE5402022', 'NPCE5473296RX', 'NPCE5566893')
