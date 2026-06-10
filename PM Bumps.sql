SELECT TOP (1000) [timestamp]
      ,[Equipment Object]
      ,[Date]
      ,[Action Code]
      ,[Serial No_]
      ,[Equipment Model]
      ,[Equipment Category]
      ,[Equipment Group]
      ,[Equipment Sub Model]
      ,[Manufacturer Code]
      ,[Type]
      ,[Description]
      ,[Calculation]
      ,[Activity]
      ,[Activity No_]
      ,[Vendor No_]
      ,[Action Group]
      ,[Priority]
      ,[Duration]
      ,[OLD Calculation Method]
      ,[Fixed Schedule Multiplier]
      ,[Fixed Schedule Step]
      ,[Early Date]
      ,[Late Date]
      ,[Expected Reading]
      ,[Maint_ Contr_ Document Type]
      ,[Maintenance Contract No_]
      ,[Customer No_]
      ,[Responsibility Center]
      ,[Cost]
      ,[Date Fixed]
      ,[Completed]
      ,[Original Date]
      ,[Change Datetime]
      ,[Change Userid]
      ,[Average M1 per Day]
      ,[Expected Actual reading]
      ,[Reason Code]
      ,[Reason Description]
  FROM [Copyofproduction ].[dbo].[Production$Service Action Planning]  LEFT OUTER JOIN
                         Production$Customer c ON [Production$Service Action Planning].[Customer No_] = c.No_
                         left join [Production$Equipment Object] e on e.No_ = [Production$Service Action Planning].[Equipment Object]
                         and [Production$Service Action Planning].[Date] = e.[Next PM Date]

  where 
  [Equipment Object] in ('294994' , 'E047632','E179944')
   --[Original Date] > [Date] 
   --and [Date Fixed] = '1' 
   --and [Date] >= '01/01/1900'
   --[Change Datetime] > '01/01/2025' 
   --[Date Fixed] = '0'


   SELECT DISTINCT([Action Code])  FROM [Copyofproduction ].[dbo].[Production$Service Action Planning]
where [Date Fixed] = '1'


---
Select No_, [Fixed Schedule Interval (Days)], [Next PM Date], [Last PM Date], [Last PM Date]-[Next PM Date] from [Production$Equipment Object] where No_ = '000407'



---BUMPS New query 
SELECT
    c.[Name], e.No_,sap.[Equipment Object], mcl.[Document No_], 
    mcl.[Status] as mclstatus,mch.[Status] as mchstatus,
    e.[Fixed Schedule Interval (Days)]              AS FixedIntervalDays,
    e.[Next PM Date]                                AS NextPMDate,
    e.[Last PM Date]                                AS LastPMDate,

    sap.[Date]                                      AS SAPDate,
    sap.[Original Date]                             AS SAPOriginalDate,
    sap.[Change Datetime]
      ,sap.[Change Userid],sap.[Responsibility Center],sap.[Type],

    -- Difference (in days) between Last PM Date and Next PM Date
    DATEDIFF(DAY, e.[Next PM Date], e.[Last PM Date]) AS DiffDays_Next_to_Last,

    -- Optional: absolute difference (often more useful for comparisons)
    ABS(DATEDIFF(DAY, e.[Next PM Date], e.[Last PM Date])) AS AbsDiffDays,

    -- Bumped flag: if the day difference is not equal to the fixed interval
    CASE
        WHEN e.[Fixed Schedule Interval (Days)] IS NULL
          OR e.[Next PM Date] IS NULL
          OR e.[Last PM Date] IS NULL
        THEN NULL

        WHEN ABS(DATEDIFF(DAY, e.[Next PM Date], e.[Last PM Date])) <> e.[Fixed Schedule Interval (Days)]
        THEN 'Bumped'
        ELSE 'Not Bumped'
    END AS BumpFlag,
    sap.[Date Fixed],sap.[Reason Code]
      ,sap.[Reason Description]

FROM [Copyofproduction].[dbo].[Production$Service Action Planning] AS sap
LEFT JOIN [Copyofproduction].[dbo].[Production$Customer] AS c
    ON sap.[Customer No_] = c.No_
LEFT JOIN [Copyofproduction].[dbo].[Production$Equipment Object] AS e
    ON e.No_ = sap.[Equipment Object]
   AND sap.[Date] = e.[Next PM Date]
left join [Production$Maintenance Contract Line] mcl on mcl.[Equipment Object] = sap.[Equipment Object]
left join [Production$Maintenance Contract Header] mch on mcl.[Document No_] = mch.[No_]
   
   where 
   --sap.[Change Userid] = '' and 
   --sap.[Date Fixed] = '1' 
   --AND ABS(DATEDIFF(DAY, e.[Next PM Date], e.[Last PM Date])) <> e.[Fixed Schedule Interval (Days)]
 --e.No_ = '' 
-- AND sap.[Change Datetime] > '12/01/2025'  
 --AND sap.[Responsibility Center] = '5'
 --and sap.[Change Datetime] > '01/01/2025' 
 --and mcl.[Status]= '3'
 --and mch.[Status] in ('0','1','2','3')
 sap.[Equipment Object] ='HE030485'
 --and e.No_ <> '';
 -- sap.[Maintenance Contract No_] <> ''
