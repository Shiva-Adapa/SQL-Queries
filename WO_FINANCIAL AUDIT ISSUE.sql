SELECT
   oh.[Responsibility Center]
 , rp.[Responsibility Center]
 , rp.[Work Type Code]
 , [Unique Number]
  , CASE ol.Type
        WHEN 0 THEN ''
        WHEN 1 THEN 'Item'
        WHEN 2 THEN 'Resource'
        WHEN 3 THEN 'Charge'
        WHEN 5 THEN 'Job Code'
        WHEN 6 THEN 'Purchase'
        WHEN 7 THEN 'Object'
        WHEN 8 THEN 'Model'
        WHEN 9 THEN 'Group(Resource)'
        WHEN 10 THEN 'Rental'
        WHEN 11 THEN 'Transport'
        ELSE ''
    END AS [Type]
  , ol.No_
  , r.[Resource Group No_]
  , c.[Customer Price Group]
  , CAST(rp.[Unit Price] AS DECIMAL(36, 2)) [Resource Unit Price]
  , ol.[Document No_]
  , CAST(oh.[Posting Date] AS DATE) [Posting Date]
  , ol.[Service Type] [WO Service Type]
  , ol.[Work Type Code] [WO Work Type Code]
  , sts.Code [Setup Code]
  , sts.[Work Type Code] [Setup Type Code]
  , CAST(ol.[Quantity Invoiced] AS DECIMAL(36, 2)) AS 'Quantity'
  , CAST(ol.[Unit Price] AS DECIMAL(36, 2)) [Unit Price]
  , CAST(ol.Amount AS DECIMAL(36, 2)) [Amount]
  , CAST((rp.[Unit Price]*ol.[Quantity Invoiced]) AS Decimal(36,2)) [Corrected Amount]
  , CAST((ol.Amount - (rp.[Unit Price]*ol.[Quantity Invoiced]))AS Decimal(36,2)) [Adjustment Needed]
  , sts.[G_L Account No_ (Cost Only)]
FROM
    [Production$Work Order Line] AS ol
    INNER JOIN [Production$Service Type Setup] sts ON ol.[Service Type] = sts.Code
                                             AND ol.Type = sts.Type
    INNER JOIN [Production$Work Order Header] AS oh ON ol.[Document No_] = oh.No_
                                                    AND ol.[Document Type] = oh.[Document Type]
    LEFT JOIN [Production$Customer] c ON c.No_ = oh.[Sell-to Customer No_]
    LEFT JOIN [Production$Resource] r ON r.No_ = ol.No_
                                      AND ol.Type = 2
    LEFT JOIN [Production$Resource Price] rp ON rp.Code = r.[Resource Group No_]
                                                AND rp.[Work Type Code] = sts.[Work Type Code]
                                                AND CASE
                                                    WHEN rp.[Responsibility Center] = oh.[Responsibility Center] THEN 1
                                                    WHEN rp.[Responsibility Center] = '' THEN 1
                                                    ELSE 0
                                                END = 1
                                                AND CASE 
                                                    WHEN rp.[Customer Price Group] = c.[Customer Price Group] THEN 1 
                                                    WHEN rp.[Customer Price Group] = '' THEN 1 ELSE 0 
                                                END = 1                                                 
WHERE
    oh.[Posting Date] >= '4/1/2024'
    AND ol.[Work Type Code] <> sts.[Work Type Code]
    --AND oh.[Responsibility Center] = '4'
    --AND ol.[Service Type] = 'SWARR'
    AND oh.No_ = 'S2687952'
    AND ol.Type = 2;