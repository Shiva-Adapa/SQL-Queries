SELECT
    ILE.[Item No_],
    I.[Blocked],
    ILE.[Demand Location],
    ILE.[Location Code],
    L.[Code] as LocationCode,

    I.[Manufacturer Code],
    I.[Item Category Code] AS ICC_Code,
    IC.[Description] AS ICC_Description,

    MAX(ILE.[Posting Date]) AS [Last Posting Date],

    -- Last purchase date
    (
        SELECT MAX(ILE2.[Posting Date])
        FROM [Copyofproduction].[dbo].[Production$Item Ledger Entry] AS ILE2
        WHERE ILE2.[Item No_] = ILE.[Item No_]
          AND ILE2.[Entry Type] = 0
    ) AS Last_Purchase_Date,

    SUM(ILE.[Remaining Quantity]) AS Remaining_Quantity,
   

    MAX(sku.[Reorder Point]) AS ReorderPoint,
    CASE 
        WHEN MAX(sku.[Reorder Point]) > 0 THEN 'Yes'
        ELSE 'No'
    END AS ReorderFlag,

    I.[Unit Cost],
    I.[Description],

    CASE
        WHEN LEN(ILE.[Location Code]) <= 2 THEN 'Central'
        ELSE 'Van'
    END AS LocationType,

    SUM(I.[Unit Cost] * ILE.[Remaining Quantity]) AS Inventory_Cost

FROM
    [Copyofproduction].[dbo].[Production$Item Ledger Entry] AS ILE

LEFT JOIN
    Production$Item AS I
        ON I.[No_] = ILE.[Item No_]

LEFT JOIN
    [Production$Item Category] AS IC
        ON I.[Item Category Code] = IC.[Code]

LEFT JOIN
    [Production$Stockkeeping Unit] AS sku
        ON ILE.[Demand Location] = sku.[Location Code]
       AND ILE.[Item No_] = sku.[Item No_]
LEFT JOIN
    [Production$Location] AS L
    ON L.[Responsibility Center] = sku.[Location Code]

where ILE.[Item No_] = 'TY00591EM12381' 
AND ILE.[Location Code] = '4' 
and L.[Code] = '832'
--AND  ILE.[Location Code] = '720'
GROUP BY
    ILE.[Item No_],
    ILE.[Location Code],
    ILE.[Demand Location],
    I.[Unit Cost],
    sku.[Reorder Point],
    I.[Blocked],
    I.[Description],
    I.[Manufacturer Code],
    I.[Item Category Code],
    IC.[Description],
    L.[Code]

HAVING
   SUM(ILE.[Remaining Quantity]) > 0;


    --select top 100* from [Production$Location]
    --where Code ='720'


SELECT * FROM [Production$Item Ledger Entry]  ILE
WHERE ILE.[Item No_] = 'DDZZ2199667' 
--AND ILE.[Demand Location] = '6' 
--AND  ILE.[Location Code] = '720'



----

SELECT * FROM [Production$Location]
where [Code] = '134' 