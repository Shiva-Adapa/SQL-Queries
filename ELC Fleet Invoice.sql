SELECT TOP (1000) [timestamp]
      ,[Document No_]
      ,[Line No_]
      ,[Sell-to Customer No_]
      ,[Type]
      ,[No_]
      ,[Location Code]
      ,[Posting Group]
      ,[Shipment Date]
      ,[Description]
      ,[Description 2]
      ,[Unit of Measure]
      ,[Quantity]
      ,[Unit Price]
      ,[Unit Cost (LCY)]
      ,[VAT %]
      ,[Line Discount %]
      ,[Line Discount Amount]
      ,[Amount]
      ,[Amount Including VAT]
      ,[Allow Invoice Disc_]
      ,[Gross Weight]
      ,[Net Weight]
      ,[Units per Parcel]
      ,[Unit Volume]
      ,[Appl_-to Item Entry]
      ,[Shortcut Dimension 1 Code]
      ,[Shortcut Dimension 2 Code]
      ,[Customer Price Group]
      ,[Job No_]
      ,[Appl_-to Job Entry]
      ,[Phase Code]
      ,[Task Code]
      ,[Step Code]
      ,[Job Applies-to ID]
      ,[Apply and Close (Job)]
      ,[Work Type Code]
      ,[Shipment No_]
      ,[Shipment Line No_]
      ,[Bill-to Customer No_]
      ,[Inv_ Discount Amount]
      ,[Drop Shipment]
      ,[Gen_ Bus_ Posting Group]
      ,[Gen_ Prod_ Posting Group]
      ,[VAT Calculation Type]
      ,[Transaction Type]
      ,[Transport Method]
      ,[Attached to Line No_]
      ,[Exit Point]
      ,[Area]
      ,[Transaction Specification]
      ,[Tax Area Code]
      ,[Tax Liable]
      ,[Tax Group Code]
      ,[VAT Bus_ Posting Group]
      ,[VAT Prod_ Posting Group]
      ,[Blanket Order No_]
      ,[Blanket Order Line No_]
      ,[VAT Base Amount]
      ,[Unit Cost]
      ,[System-Created Entry]
      ,[Line Amount]
      ,[VAT Difference]
      ,[VAT Identifier]
      ,[IC Partner Ref_ Type]
      ,[IC Partner Reference]
      ,[Variant Code]
      ,[Bin Code]
      ,[Qty_ per Unit of Measure]
      ,[Unit of Measure Code]
      ,[Quantity (Base)]
      ,[FA Posting Date]
      ,[Depreciation Book Code]
      ,[Depr_ until FA Posting Date]
      ,[Duplicate in Depreciation Book]
      ,[Use Duplication List]
      ,[Responsibility Center]
      ,[Cross-Reference No_]
      ,[Unit of Measure (Cross Ref_)]
      ,[Cross-Reference Type]
      ,[Cross-Reference Type No_]
      ,[Item Category Code]
      ,[Nonstock]
      ,[Purchasing Code]
      ,[Product Group Code]
      ,[Appl_-from Item Entry]
      ,[Service Contract No_]
      ,[Service Order No_]
      ,[Service Item No_]
      ,[Appl_-to Service Entry]
      ,[Service Item Line No_]
      ,[Serv_ Price Adjmt_ Gr_ Code]
      ,[Return Reason Code]
      ,[Allow Line Disc_]
      ,[Customer Disc_ Group]
      ,[Package Tracking No_]
      ,[Order No_]
      ,[Order Line No_]
      ,[Posting Date]
      ,[Contract Type]
      ,[Contract No_]
      ,[Contract Line No_]
      ,[Equipment Category]
      ,[Equipment Group]
      ,[Equipment Model]
      ,[Equipment Object]
      ,[Entry Type]
      ,[Invoice Period from]
      ,[Invoice Period till]
      ,[Catalogue No_]
      ,[Physical Object]
      ,[Trade In Book Value]
      ,[Trade in Book Value Override]
      ,[Work Order Type]
      ,[Work Order No_]
      ,[Work Order Line No_]
      ,[Serial No_]
      ,[Source Type]
      ,[Source No_]
      ,[Requisition Code]
      ,[Buy from Vendor]
      ,[Available]
      ,[Message Price && Availability]
      ,[Qty_ Ordered]
      ,[Qty_ Ordered (Base)]
      ,[Normal Order]
      ,[Normal Order Purchase No_]
      ,[Normal Order Purch_ Line No_]
      ,[Claim Amount]
      ,[Do Not Print]
      ,[Aftersales Cost]
      ,[Project No_]
      ,[Project Task]
      ,[Project Task Line No_]
      ,[Financing Amount]
      ,[Financing No_]
      ,[Financing Line No_]
      ,[Total Together]
      ,[Equipment Configurator No_]
      ,[Internal Comment elc16]
      ,[Rental Currency]
      ,[Internal Comment elc17]
      ,[Commission code]
      ,[Commission Line]
      ,[Commission Amount]
      ,[Commission]
      ,[Invoice Period from Date]
      ,[Invoice Period from Time]
      ,[Invoice Period till Date]
      ,[Invoice Period till Time]
      ,[Reporting Code]
      ,[Belong to Main Object]
      ,[Prepayment Line]
      ,[IC Partner Code]
      ,[Job Task No_]
      ,[Job Contract Entry No_]
      ,[Invoice Period M1 Start]
      ,[Course No_]
      ,[Prepayment Qty_]
      ,[Prepayment Amount]
      ,[Previous Prepayment Amount]
      ,[Belong to Prepayment Line No_]
      ,[Prepayment Detail Line]
      ,[Prepayment %]
      ,[Invoice Period M1 Finish]
      ,[Invoice Period M1]
      ,[Overtime Period]
      ,[Meter Reading Group]
      ,[Expected Usage]
      ,[ELC Doc_ Type]
      ,[ELC Document No_]
      ,[Contract Period]
      ,[Auto Acc_ Group ELC]
      ,[Periodic Template Code ELC]
      ,[Periodic Starting Date ELC]
      ,[Project Term No_]
      ,sum([Amount]) as Amount
  FROM [Copyofproduction ].[dbo].[Production$Sales Invoice Line]
  WHERE [Bill-to Customer No_] = 'C107777' AND [Posting Date] = '12/10/2025'
  Group by [Document No_]

  -------------

select SL.[Responsibility Center],SL.[Document No_],WOH.[Starting Date],WOH.[Finishing Date],RH.[Starting Date],RH.[Finishing Date], SL.[Posting Date], SL.[Serial No_],WOH.[Service Type],WOH.[Status]
      
     ,sum(SL.[Amount]) as Amount
  FROM [Copyofproduction ].[dbo].[Production$Sales Invoice Line] as SL
  LEFT JOIN [Production$Work Order Header] AS WOH on SL.[Document No_]=WOH.No_
  left join [Production$Sales Invoice Header] SH on SL.[Document No_] = SH.No_
  left join [Production$Rental Contract Header] RH on SL.[Document No_] LIKE RH.No_ + '%'
  WHERE SL.[Bill-to Customer No_] = 'C107777' AND SL.[Posting Date] >= '01/01/2025' 
  --and [Document No_] like 'S3197364'
  and SH.[Credit invoice No_] = ''
  Group by SL.[Document No_],SL.[Document No_], SL.[Posting Date], SL.[Serial No_],WOH.[Service Type],SL.[Responsibility Center],
  WOH.[Status],WOH.[Starting Date],WOH.[Finishing Date],RH.[Starting Date],RH.[Finishing Date]
      

      ------
      select * 
      FROM [Copyofproduction ].[dbo].[Production$Sales Invoice Line] as SL
  LEFT JOIN [Production$Work Order Header] AS WOH on SL.[Document No_]=WOH.No_
  left join [Production$Sales Invoice Header] SH on SL.[Document No_] = SH.No_
  WHERE SL.[Bill-to Customer No_] = 'C107777' AND SL.[Posting Date] >= '01/01/2025' 
  and SL.[Document No_] like 'S3197364%' and SH.[Credit invoice No_] = ''
  --Group by SL.[Document No_],SL.[Document No_], SL.[Posting Date], SL.[Serial No_],WOH.[Service Type],SL.[Responsibility Center],WOH.[Status]
      


      ----- updated query for ssingle starting date 

      SELECT
    SL.[Responsibility Center],
    SL.[Document No_],

    COALESCE(WOH.[Starting Date], RH.[Starting Date])   AS [Starting Date],
    COALESCE(WOH.[Finishing Date], RH.[Finishing Date]) AS [Finishing Date],

    SL.[Posting Date],
    SL.[Serial No_],
    WOH.[Service Type],
    WOH.[Status],
    SUM(SL.[Amount]) AS Amount
FROM [Copyofproduction ].[dbo].[Production$Sales Invoice Line] AS SL
LEFT JOIN [Production$Work Order Header] AS WOH
    ON SL.[Document No_] = WOH.No_
LEFT JOIN [Production$Sales Invoice Header] AS SH
    ON SL.[Document No_] = SH.No_
LEFT JOIN [Production$Rental Contract Header] AS RH
    ON SL.[Document No_] LIKE RH.No_ + '%'
WHERE
    SL.[Bill-to Customer No_] = 'C107777'
    AND SL.[Posting Date] >= '2025-01-01'
    AND SH.[Credit invoice No_] = ''
GROUP BY
    SL.[Responsibility Center],
    SL.[Document No_],
    COALESCE(WOH.[Starting Date], RH.[Starting Date]),
    COALESCE(WOH.[Finishing Date], RH.[Finishing Date]),
    SL.[Posting Date],
    SL.[Serial No_],
    WOH.[Service Type],
    WOH.[Status];
