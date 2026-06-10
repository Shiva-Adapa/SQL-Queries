SELECT
    Work_Order_Header.[Responsibility Center],
    Work_Order_Header.[Sell-to Customer Name],
    Work_Order_Header.[Equipment Object],
    Work_Order_Header.[Object Description],
    Equipment_Object.[Sales Order Date],
    Equipment_Object.[Expected Receipt Date],
    Work_Order_Header.No_,
    Purch__Rcpt__Line.[Posting Date] AS RcptPostingDate,
    Equipment_Object.[Expected Delivery Date],
    Work_Order_Header.[Posting Date],
    Equipment_Object.[Sales Date],
    MIN([Production$Hour Line].[Starting Date]) AS [First Labor],
    MAX([Production$Hour Line].[Finishing Date]) AS [Last Labor],
    SUM([Production$Hour Line].Hours) AS [Sum of Hours],
    Purchase_Line.[Order Date],
    Equipment_Object.[Sales Order No_] AS [Document No],
    Work_Order_Header.Status,
    Sales_Header.[Shipment Date],
    Sales_Header.[Salesperson Code],
    Sales_Header.[Payment Method Code],
    Work_Order_Header.[Starting Date],
    Work_Order_Header.[Finishing Date],
    Work_Order_Header.[Service Type],
    Work_Order_Header.[Bill-to Customer No_],
    Work_Order_Header.[Bill-to Name],
    Purch__Rcpt__Line.[Unit Cost (LCY)] AS RcptCost,
    Equipment_Object.[Posting Date] AS ObjectPostingDate,
    Equipment_Object.[Last Modification],
    Equipment_Object.Status AS ObjectStatus,
    Equipment_Object.[Installation Date],
    Equipment_Object.[Equipment Model],
    Equipment_Object.[Serial No_],
    Equipment_Object.[Rental Status],
    Equipment_Object.[Responsibility Center] AS S_ResponsibilityCenter
FROM [Production$Work Order Header] AS Work_Order_Header
    INNER JOIN [Production$Equipment Object] AS Equipment_Object
        ON Equipment_Object.No_ = Work_Order_Header.[Equipment Object]
    INNER JOIN [Production$Sales Header] AS Sales_Header
        ON Equipment_Object.[Sales Order No_] = Sales_Header.No_
    LEFT OUTER JOIN [Production$Hour Line]
        ON Work_Order_Header.No_ = [Production$Hour Line].[Work Order No_]
    LEFT OUTER JOIN [Production$Purchase Line] AS Purchase_Line
        ON Purchase_Line.No_ = Work_Order_Header.[Equipment Object]
    LEFT OUTER JOIN [Production$Purch_ Rcpt_ Line] AS Purch__Rcpt__Line
        ON Purch__Rcpt__Line.No_ = Work_Order_Header.[Equipment Object]
WHERE (Work_Order_Header.[Service Type] LIKE 'NPDI%')
    AND (Work_Order_Header.[Document Type] = '1')
    AND (
        Purch__Rcpt__Line.[Physical Object] = '1'
        OR Purch__Rcpt__Line.[Physical Object] IS NULL
    )
    AND (
        Purch__Rcpt__Line.Quantity = '1'
        OR Purch__Rcpt__Line.Quantity IS NULL
    )
    AND (
        Purchase_Line.[Physical Object] = '1'
        OR Purchase_Line.[Physical Object] IS NULL
    ) and Equipment_Object.[Equipment Model] = '7FBCU45'
GROUP BY
    Work_Order_Header.[Responsibility Center],
    Work_Order_Header.[Sell-to Customer Name],
    Work_Order_Header.[Equipment Object],
    Work_Order_Header.[Object Description],
    Equipment_Object.[Sales Order Date],
    Equipment_Object.[Expected Receipt Date],
    Work_Order_Header.No_,
    Purch__Rcpt__Line.[Posting Date],
    Equipment_Object.[Expected Delivery Date],
    Work_Order_Header.[Posting Date],
    Equipment_Object.[Sales Date],
    Purchase_Line.[Order Date],
    Equipment_Object.[Sales Order No_],
    Work_Order_Header.Status,
    Sales_Header.[Shipment Date],
    Sales_Header.[Salesperson Code],
    Sales_Header.[Payment Method Code],
    Work_Order_Header.[Starting Date],
    Work_Order_Header.[Finishing Date],
    Work_Order_Header.[Service Type],
    Work_Order_Header.[Bill-to Customer No_],
    Work_Order_Header.[Bill-to Name],
    Purch__Rcpt__Line.[Unit Cost (LCY)],
    Equipment_Object.[Posting Date],
    Equipment_Object.[Last Modification],
    Equipment_Object.Status,
    Equipment_Object.[Installation Date],
    Equipment_Object.[Equipment Model],
    Equipment_Object.[Serial No_],
    Equipment_Object.[Rental Status],
    Equipment_Object.[Responsibility Center]
HAVING Work_Order_Header.Status <> 'CLOSE'
ORDER BY Work_Order_Header.No_;





---- EO

SELECT * FROM [Production$Equipment Object]
 WHERE 
 [Equipment Model] in ( '8FGCU55BCS'
    ,'7FBCU35'
 , '7FBCU35','7FBCU55'
 ) 
  and
 [Responsibility Center] = '4' 
 AND [Year] >= '2025'