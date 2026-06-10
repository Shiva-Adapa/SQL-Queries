
WITH EntryTypeSums AS (
    SELECT 
        Equipment_Object.[Equipment Category],
        Equipment_Value_Entry.[Equipment Object], 
        
        -- Summing amounts by entry type
        SUM(CASE WHEN Equipment_Value_Entry.[Entry Type] in ('0','15','18','20') THEN CAST(Equipment_Value_Entry.Amount AS DECIMAL(38, 10)) ELSE 0 END) AS Total_Purchase,
        SUM(CASE WHEN Equipment_Value_Entry.[Entry Type] = '11' THEN CAST(Equipment_Value_Entry.Amount AS DECIMAL(38, 10)) ELSE 0 END) AS Total_Enhancement,
        SUM(CASE WHEN Equipment_Value_Entry.[Entry Type] = '17' THEN CAST(Equipment_Value_Entry.Amount AS DECIMAL(38, 10)) ELSE 0 END) AS Total_Depreciation,
        SUM(CASE WHEN Equipment_Value_Entry.[Entry Type] = '37' THEN CAST(Equipment_Value_Entry.Amount AS DECIMAL(38, 10)) ELSE 0 END) AS Total_Adjustment,
       SUM(CASE WHEN Equipment_Value_Entry.[Entry Type] IN ('0','37','11') THEN CAST(Equipment_Value_Entry.Amount AS DECIMAL(38, 10)) ELSE 0 END) AS Total_Amount

    FROM [Production$Equipment Object] AS Equipment_Object
    /**LEFT JOIN [Production$Purchase Line] 
        ON Equipment_Object.No_ = [Production$Purchase Line].No_
    LEFT JOIN [Production$Purchase Header] 
        ON [Production$Purchase Line].[Document No_] = [Production$Purchase Header].No_**/
    LEFT JOIN [Production$Equipment Value Entry] AS Equipment_Value_Entry 
        ON Equipment_Object.No_ = Equipment_Value_Entry.[Equipment Object]

    WHERE 
        
    (Equipment_Object.Status NOT IN ('STOCK/SOLD', 'DONOTSHOW', 'RENTED', 'RPO')
    AND (Equipment_Object.[Posting Status] = 2 ) 
    AND Equipment_Object.Blocked = 0
    --AND Equipment_Object.[Purchase Date] > 0
    --AND ([Production$Purchase Line].[Physical Object] = 1 OR [Production$Purchase Line].[Physical Object] IS NULL)
    --AND ([Production$Purchase Line].Quantity = 1 OR [Production$Purchase Line].Quantity IS NULL)
    --AND ([Production$Purchase Line].[Document Type] = 1 OR [Production$Purchase Line].[Document Type] IS NULL)
    AND (Equipment_Value_Entry.[Entry Type] IN ('0','11', '17', '37','15','18','20'))
    --AND Equipment_Value_Entry.[Equipment Object] IN ('E199998')
    )
    or
     (
        Equipment_Object.Status = 'CONSIGN'
        AND Equipment_Object.[Posting Status] = 2 --STOCK
        AND Equipment_Object.Blocked = 0
        --AND ([Production$Purchase Line].[Physical Object] = 1 OR [Production$Purchase Line].[Physical Object] IS NULL)
        --AND ([Production$Purchase Line].Quantity = 1 OR [Production$Purchase Line].Quantity IS NULL)
    ) 
 OR 
    (
        Equipment_Object.Status <> 'DONOTSHOW'
        AND Equipment_Object.[Posting Status] = 3 -- DEMO
        AND Equipment_Object.Blocked = 0
        AND Equipment_Value_Entry.[Entry Type] IN ('0','11', '17', '37','15','18','20')
       -- AND Equipment_Value_Entry.[Equipment Object] IN ('E174879')
    ) 
  OR
     (
        Equipment_Object.Status = 'DEMO'
        AND Equipment_Object.[Posting Status] = 4  --RENTAL
    ) 

    GROUP BY Equipment_Value_Entry.[Equipment Object],Equipment_Object.[Equipment Category]
)

-- Final book value calculation
SELECT
[Equipment Category],
    [Equipment Object],
   Total_Purchase, 
    Total_Enhancement, 
   Total_Depreciation, 
    Total_Adjustment,
    
    -- Calculating Book Value
    (Total_Purchase + Total_Enhancement - Total_Depreciation + Total_Adjustment) AS Book_Value

FROM EntryTypeSums
WHERE [Equipment Object] ='E106015'
group by  [Equipment Category],[Equipment Object]
, Total_Purchase, 
    Total_Enhancement, 
    Total_Depreciation, 
    Total_Adjustment





    ---- EQUIP STOCK NEW---
    SELECT  
    CASE 
        WHEN Equipment_Object.[Equipment Group] IN ('COMBILIFT', 'COMBILIFT LARGE', 'AILSEMASTER') 
            THEN 'COMBI-AISLE'
        ELSE Equipment_Object.[Equipment Group]
    END AS [Equipment Group],

    [Production$Purchase Line].[Document Type],

    CASE 
        WHEN Equipment_Object.[Equipment Category] = 'SPECIALIZED LARGE' 
            THEN 'SPECIALIZED'
        ELSE Equipment_Object.[Equipment Category]
    END AS [Equipment Category],

    Equipment_Value_Entry.[Equipment Object],
    Equipment_Object.[Default Rental Return Location],

    CASE  
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = '' THEN 'NA'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 1  THEN 'Louisville'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 2  THEN 'Columbus (NPDI)'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 3  THEN 'Indianapolis'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 4  THEN 'Dayton'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 5  THEN 'Lexington'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 6  THEN 'Cincinnati'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 7  THEN 'Evansville'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 8  THEN 'West Virginia'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 9  THEN 'Erlanger'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 10 THEN 'Warehouse Solutions'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 11 THEN 'Tire Central'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 14 THEN 'TMMK'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 15 THEN 'TMMWV'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 20 THEN 'Specialty Products'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 21 THEN 'Corporate'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 31 THEN 'Cleveland'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 32 THEN 'Toledo'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 33 THEN 'Columbus OH'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 39 THEN 'TMH Corporate'
        WHEN TRY_CAST(Equipment_Object.[Default Rental Return Location] AS INT) = 40 THEN 'TRANSIT'
        ELSE 'Unknown'
    END AS [CSC_Name1],

    Equipment_Object.[Licence Plate No_],
    Equipment_Object.[Equipment Model],
    Equipment_Object.[Serial No_],
    Equipment_Object.[Description],
    Equipment_Object.[Status],
    Equipment_Object.[Date2],
   -- SUM(CAST(Equipment_Value_Entry.Amount AS DECIMAL(38, 10))) AS [Amount],
    CAST(Equipment_Value_Entry.Amount AS DECIMAL(38, 10)) AS [Amount],
    Equipment_Object.[Reporting Code],

    CASE Equipment_Object.[Posting Status]
        WHEN 0  THEN 'Configuration'
        WHEN 1  THEN 'Order'
        WHEN 2  THEN 'Stock'
        WHEN 3  THEN 'Demo'
        WHEN 4  THEN 'Rental'
        WHEN 5  THEN 'Used'
        WHEN 6  THEN 'Consumed'
        WHEN 7  THEN 'Delivered'
        WHEN 8  THEN 'Sold'
        WHEN 9  THEN 'Returned to Dealer/Vendor'
        WHEN 10 THEN 'Service only'
        WHEN 11 THEN 'Steppingstone'
        WHEN 12 THEN 'Stolen'
        WHEN 13 THEN 'Scrapped'
        WHEN 14 THEN 'Rerent'
        WHEN 15 THEN 'Deactivated'
        WHEN 16 THEN 'Leased'
        WHEN 17 THEN 'Rerent IC'
        WHEN 18 THEN 'Service IC'
        ELSE ''
    END AS [Posting Status Description],

    CASE 
        WHEN Equipment_Object.[Equipment Category] IN 
            ('ATTACHMENTS', 'BATTERY/CHARGER', 'DOCK/DOOR', 'MISCELLANEOUS', 'OTHER', 'MAINTENANCE EQUIP') 
            THEN 'Stock Attachment'
        WHEN Equipment_Object.[Equipment Group] = 'ALLIED' 
            THEN 'Stock Attachment'
        WHEN Equipment_Object.[Posting Status] = 3 
            THEN 'Demo Equipment'
        ELSE 'Stock Equipment'
    END AS [Type],

    Equipment_Value_Entry.[Source Code],
    Equipment_Value_Entry.[Entry Type],
    Equipment_Value_Entry.[Posting Date],
    Equipment_Object.[Purchase Date],
    --Equipment_Value_Entry.[Posting Date],
    [Production$Purchase Header].[Vendor Shipment No_],
    [Production$Purchase Line].[Document Type],
    Equipment_Object.Blocked

FROM [Production$Equipment Object] AS Equipment_Object

LEFT JOIN [Production$Equipment Value Entry] AS Equipment_Value_Entry
    ON Equipment_Object.No_ = Equipment_Value_Entry.[Equipment Object]
    LEFT JOIN [Production$Purchase Line]
    ON Equipment_Value_Entry.[Equipment Object]= [Production$Purchase Line].No_ 
    --and [Production$Purchase Line].[Document No_] =
LEFT JOIN [Production$Purchase Header]
    ON [Production$Purchase Line].[Document No_] = [Production$Purchase Header].No_

WHERE 
    (Equipment_Value_Entry.[Equipment Object] = 'E106015' AND
        Equipment_Object.Status = 'STOCK'
        --NOT IN ('STOCK/SOLD', 'DONOTSHOW', 'RENTED', 'RPO')
        AND Equipment_Object.[Posting Status] = 2 and
        ([Production$Purchase Line].[Document Type] = 1 OR [Production$Purchase Line].[Document Type] IS NULL)
        AND (Equipment_Value_Entry.[Source Code] IN ('ELC01', 'ELC04', 'ELC18') )
    )

/**GROUP BY
    CASE 
        WHEN Equipment_Object.[Equipment Group] IN ('COMBILIFT', 'COMBILIFT LARGE', 'AILSEMASTER') 
            THEN 'COMBI-AISLE'
        ELSE Equipment_Object.[Equipment Group]
    END,
    [Production$Purchase Line].[Document Type],
    CASE 
        WHEN Equipment_Object.[Equipment Category] = 'SPECIALIZED LARGE' 
            THEN 'SPECIALIZED'
        ELSE Equipment_Object.[Equipment Category]
    END,
    Equipment_Value_Entry.[Equipment Object],
    Equipment_Object.[Default Rental Return Location],
    Equipment_Object.[Licence Plate No_],
    Equipment_Object.[Equipment Model],
    Equipment_Object.[Serial No_],
    Equipment_Object.[Description],
    Equipment_Object.[Status],
    Equipment_Object.[Date2],
    Equipment_Object.[Reporting Code],
    Equipment_Object.[Posting Status],
    Equipment_Value_Entry.[Source Code],
    Equipment_Object.[Purchase Date],
    --Equipment_Value_Entry.[Posting Date],
    [Production$Purchase Header].[Vendor Shipment No_],
    Equipment_Object.Blocked,
    CASE 
        WHEN Equipment_Object.[Equipment Category] IN 
            ('ATTACHMENTS', 'BATTERY/CHARGER', 'DOCK/DOOR', 'MISCELLANEOUS', 'OTHER', 'MAINTENANCE EQUIP') 
            THEN 'Stock Attachment'
        WHEN Equipment_Object.[Equipment Group] = 'ALLIED' 
            THEN 'Stock Attachment'
        WHEN Equipment_Object.[Posting Status] = 3 
            THEN 'Demo Equipment'
        ELSE 'Stock Equipment'
    END;**/


    select *
    --[Equipment Object], [Entry Type], [Amount], [Source Code] 
    from [Production$Equipment Value Entry]
    where [Equipment Object] = 'HE025301' and [Source Code] IN ('ELC01', 'ELC04', 'ELC18')


    select top 100* from [Production$Purchase Line] where 
    No_= 'HE025301'--'E106015'