SELECT TOP (1000) 
      h.[Document Type]
      ,h.[No_]
      ,h.[Sell-to Customer No_]
      ,h.[Bill-to Customer No_]
  
      
  
      
      ,h.[Sell-to Customer Name]
   
    
      ,h.[Posting Status]
      ,h.[Status]
     
      ,h.[Starting Date]
      
      ,h.[Finishing Date]
      
      ,h.[Posting Date]
      ,h.[Posting Time]
    
   
      ,h.[Equipment Object]
      ,h.[Equipment Category]
      ,h.[Equipment Group]
      ,h.[Object Description]
      ,h.[Serial No_]
      ,h.[Fleet Code]
     

      ,h.[Service Type]
 
      ,h.[Contract Type]
    
      
 
      ,h.[Responsibility Center]
      
 
     
  ,h.[Posting Datetime]
   ,l.[Unit Price]
    
      ,l.[Unit Cost]
     
      ,l.[Amount]
     
      ,l.[Amount incl_ Tax]
      ,l.[Quantity Used]
      
      ,l.[Quantity Invoiced]
  FROM [Copyofproduction ].[dbo].[Production$Work Order Header]  h
  left join [Production$Work Order Line] l
  on h.[No_] =l.[Document No_] and h.[Responsibility Center]=l.[Responsibility Center]

where h.[Posting Status] = '2' --- 0=open,1=released, 2=closed, 3=lost order
and h.[Service Type] in ('RRENT','RPM','USEDRENTPM','USEDRENTAL','FLEXRENTAL','FLEXRENTPM')
AND h.[Responsibility Center] = '5' and ([Posting Date] between '04/01/2025' and '04/30/2025')
--AND h.[Equipment Object] = 'E077979'


---- Rental Billing Maintenance Cost----------
select h.[Responsibility Center],h.[Service Type], sum(l.[Amount]) as [Rental Maintnance Cost],h.[Posting Date]

 FROM [Copyofproduction ].[dbo].[Production$Work Order Header]  h
  left join [Production$Work Order Line] l
  on h.[No_] =l.[Document No_] and h.[Responsibility Center]=l.[Responsibility Center]

where h.[Posting Status] = '2' --- 0=open,1=released, 2=closed, 3=lost order
and h.[Service Type] in ('RRENT','RPM','USEDRENTPM','USEDRENTAL','FLEXRENTAL','FLEXRENTPM')
AND h.[Responsibility Center] = '5' 
and (h.[Posting Date] between '05/01/2025' and '05/31/2025')
group by h.[Responsibility Center],h.[Posting Date],h.[Service Type]


----TEST PBI M COST RENTAL  -- for may 468682.25 not matching with GL
select  sum(l.[Amount]) 
FROM [Copyofproduction ].[dbo].[Production$Work Order Header]  h
  left join [Production$Work Order Line] l
  on h.[No_] =l.[Document No_] 
  and h.[Responsibility Center]=l.[Responsibility Center]

where h.[Posting Status] = '2' --- 0=open,1=released, 2=closed, 3=lost order
and h.[Service Type] in ('RRENT','RPM','USEDRENTPM','USEDRENTAL','FLEXRENTAL','FLEXRENTPM', 'RERENT','RPO','RPO PM','TIRE-RENT', 'RRERENT','RERENTPM','TRANS-RENT')
--AND h.[Responsibility Center] = '5' 
and (h.[Posting Date] between '05/01/2025' and '05/31/2025')



---
SELECT distinct [Service Type],[Description] from [Production$Work Order Header] 
---



---Rental Revenue

SELECT 
                GL.[Document No_] AS [Document Number],
                GL.Amount,
                GL.[Equipment Object] AS [Equipment Number],
                GL.[Posting Date],
                SIH.[Responsibility Center] AS [CSC Code],
                SIH.[ELC Doc_ Type] AS [DocType Code],
                EO.[Default Rental Return Location],
                EO.[Equipment Category],
                EO.[Equipment Group],
                EO.[Equipment Model],
                h.[Service Type],
                EO.[Contract Type],
                SIH.[Ship-to Address],
                SIH.[Ship-to City],
                SIH.[Ship-to County],
                SIH.[Ship-to Post Code],
                GL.[G_L Account No_]
             FROM [Production$G_L Entry] AS GL
             LEFT JOIN [Production$Sales Invoice Header] AS SIH ON SIH.No_ = GL.[Document No_]
             LEFT JOIN [Production$Equipment Object] AS EO ON GL.[Equipment Object] = EO.No_
             left join [Production$Work Order Header] h on h.[Equipment Object] =EO.No_ 
             AND h.No_= SIH.No_
             WHERE 
                GL.[G_L Account No_] >= '55070'
                AND GL.[G_L Account No_] <= '55086'
                --and SIH.[Responsibility Center] = '1'
                --and  h.[Service Type] like 'R%'
                --AND GL.[Document No_] = 'RO-007918'
                and GL.[Posting Date] between '05/01/2025' and '05/31/2025'


--- GL Rental Main Cost is captured acccurately, 
--now need to compare it with WOL amount for rental service types and find out the difference of 38,950$ difference for May 2025


SELECT 
                 sum(GL.Amount) as Rental_Maintenance_Cost_GL,h.[Responsibility Center],CAST(GL.[Posting Date] AS DATE) AS [Posting Date],h.[Service Type]
FROM [Production$G_L Entry] AS GL
             LEFT JOIN [Production$Sales Invoice Header] AS SIH ON SIH.No_ = GL.[Document No_]
             LEFT JOIN [Production$Equipment Object] AS EO ON GL.[Equipment Object] = EO.No_
             left join [Production$Work Order Header] h on h.[Equipment Object] =EO.No_ 
             AND h.No_= SIH.No_
             WHERE 
                GL.[G_L Account No_] >= '55070'
                AND GL.[G_L Account No_] <= '55086' --- ARE These GL's captured from work order line amount column for the rent specific service types?
                --and SIH.[Responsibility Center] = '1'
                --and  h.[Service Type] like 'R%'
                --AND GL.[Document No_] = 'RO-007918'
                and GL.[Posting Date] between '05/01/2025' and '05/31/2025'  --- value is matching with GL  $ 507632.36
group by h.[Responsibility Center],GL.[Posting Date],h.[Service Type]
--

--  
select top 100 *
FROM [Production$G_L Entry]


--Rental Revenue 
select sum(GL.[Amount])
FROM [Production$G_L Entry] AS GL
             --LEFT JOIN [Production$Sales Invoice Header] AS SIH ON SIH.No_ = GL.[Document No_]
             --LEFT JOIN [Production$Equipment Object] AS EO ON GL.[Equipment Object] = EO.No_
             --left join [Production$Work Order Header] h on h.[Equipment Object] =EO.No_
             WHERE 
                GL.[G_L Account No_] IN ('45005','45007','45010','45070','45030','45020','45015','45080','45075') --- MATCHING WITH Pbi  -- net rental sales (total rental revenue - rental discounts)
                --AND GL.[G_L Account No_] <= '45099'
                --and SIH.[Responsibility Center] = '1'
                and GL.[Posting Date] BETWEEN '05/01/2025' AND '05/31/2025'



--- Rental utilization Rental MAINTENANCE split based on service type regroup
SELECT  
      H.[Responsibility Center],
      H.[Service Type],
      SUM(L.[Amount]) AS [Rental Maintenance Cost],
      H.[Posting Date]

FROM [Copyofproduction].[dbo].[Production$Work Order Header] AS H
LEFT JOIN [Copyofproduction].[dbo].[Production$Work Order Line] AS L
       ON H.[No_] = L.[Document No_]
      AND H.[Responsibility Center] = L.[Responsibility Center]

WHERE H.[Posting Status] = '2'      -- 0 = Open, 1 = Released, 2 = Closed, 3 = Lost order
  AND H.[Service Type] IN (
        'RRENT','RPM','USEDRENTPM','USEDRENTAL','FLEXRENTAL','FLEXRENTPM',
        'RERENT','RPO','RPO PM','TIRE-RENT','RRERENT','RERENTPM',
        'TRANS-RENT','RCUSTREP','RDEL'
      )
  -- AND H.[Responsibility Center] = '5'
  -- AND H.[Posting Date] BETWEEN '2025-04-01' AND '2025-04-30'

GROUP BY  
      H.[Responsibility Center],H.[Service Type],
      H.[Posting Date];



---rental fleet type classification column added 

SELECT   
      H.[Responsibility Center],
      H.[Service Type],

      CASE 
            WHEN H.[Service Type] IN ('RRENT','RPM') 
                  THEN 'ST & LT'
            WHEN H.[Service Type] IN ('RERENT') 
                  THEN 'Sublets'
            WHEN H.[Service Type] IN ('USEDRENTAL','USEDRENTPM') 
                  THEN 'Used on Rent'
            WHEN H.[Service Type] IN ('FLEXRENTAL','FLEXRENTPM') 
                  THEN 'FLEX'
            ELSE 'OTHER'
      END AS [Rental Fleet Type Classification],

      SUM(L.[Amount]) AS [Rental Maintenance Cost],
      H.[Posting Date]

FROM [Copyofproduction].[dbo].[Production$Work Order Header] AS H
LEFT JOIN [Copyofproduction].[dbo].[Production$Work Order Line] AS L
       ON H.[No_] = L.[Document No_]
      AND H.[Responsibility Center] = L.[Responsibility Center]

WHERE H.[Posting Status] = '2'
  AND H.[Service Type] IN (
        'RRENT','RPM','USEDRENTPM','USEDRENTAL','FLEXRENTAL','FLEXRENTPM',
        'RERENT','TIRE-RENT','RRERENT','RERENTPM',
        'TRANS-RENT','RCUSTREP','RDEL'
      )

GROUP BY  
      H.[Responsibility Center],
      H.[Service Type],
      H.[Posting Date],
      CASE 
            WHEN H.[Service Type] IN ('RRENT','RPM') 
                  THEN 'ST & LT'
            WHEN H.[Service Type] IN ('RERENT') 
                  THEN 'Sublets'
            WHEN H.[Service Type] IN ('USEDRENTAL','USEDRENTPM') 
                  THEN 'Used on Rent'
            WHEN H.[Service Type] IN ('FLEXRENTAL','FLEXRENTPM') 
                  THEN 'FLEX'
            ELSE 'OTHER'
      END;


---- Revenue Rental 

SELECT 
                GL.[Document No_] AS [Document Number],
                GL.Amount,
                GL.[Equipment Object] AS [Equipment Number],
                GL.[Posting Date],
                SIH.[Responsibility Center] AS [CSC Code],
                SIH.[ELC Doc_ Type] AS [DocType Code],
                EO.[Default Rental Return Location],
                EO.[Equipment Category],
                EO.[Equipment Group],
                EO.[Equipment Model],
                SIH.[Ship-to Address],
                SIH.[Ship-to City],
                SIH.[Ship-to County],
                SIH.[Ship-to Post Code],
                GL.[G_L Account No_]
             FROM [Production$G_L Entry] AS GL
             LEFT JOIN [Production$Sales Invoice Header] AS SIH ON SIH.No_ = GL.[Document No_]
             INNER JOIN [Production$Sales Invoice Line] SIL
    ON SIH.No_ = SIL.[Document No_]
             LEFT JOIN [Production$Equipment Object] AS EO ON GL.[Equipment Object] = EO.No_
             WHERE 
                GL.[G_L Account No_] >= '45000'
                AND GL.[G_L Account No_] <= '45099'