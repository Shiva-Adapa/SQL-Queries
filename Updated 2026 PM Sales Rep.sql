 ----PM Sales Reps


        SELECT 
    pmch.[Responsibility Center] as CSC,
    pmch.[Order Manager] as [Salesrep on MC],
    pmch.[Sell-to Customer No_],
    pmch.[Sell-to Customer Name],
    c.[Salesperson Service] as [Salesperson No_],
    sp1.[Name] AS [Salesperson Name],
    sp1.[E-Mail] AS [Salesperson Email],
    EO.[Customer No_] as [Customer No],
    c.[Name] AS [Customer Name],
    c.[Address] AS C_Address,
    c.[City] AS C_City,
    c.[County] AS C_State,
    c.[Post Code] AS C_ZipCode,
    c.[Blocked], 
    c.[Manual Blocked], 
    c.[Salesperson Code],
    pmch.[No_] as [Contract No.],
    pmch.[Contract Type] AS ContractType,
    EO.[No_] AS [Equipment Object],
    CAST(pmch.[Finishing Date] AS DATE) AS [Contract Finish Date], 
    CAST(mcl.[Starting Date] AS DATE) AS LineStartDate,
    CAST(mcl.[Finishing Date] AS DATE) AS LineFinishDate, 
    EO.[Fixed Schedule Interval (Days)] AS IntervalDays, 
    CAST(sao.[Agreed Price] AS DECIMAL(38,2)) AS [Agreed Price], 
    --sp.[E-Mail] AS [Salesperson Email],
    --sp1.[Name] AS OM_Name,
    mcl.[Document No_] AS MaintenanceContract,
    CASE EO.[Posting Status] 
        WHEN 0 THEN 'Configuration'
        WHEN 1 THEN 'Order'
        WHEN 2 THEN 'Stock'
        WHEN 3 THEN 'Demo'
        WHEN 4 THEN 'Rental'
        WHEN 5 THEN 'Used'
        WHEN 6 THEN 'Consumed'
        WHEN 7 THEN 'Delivered'
        WHEN 8 THEN 'Sold'
        WHEN 9 THEN 'Returned to Dealer/Vendor'
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
    END AS PostingStatus, 
    CAST(sao.[Last Date] AS DATE) AS LastPMDate, 
    CAST(sao.[Next Planned Date] AS DATE) AS NextPMDate, 
    DATEDIFF(DAY, GETDATE(), sao.[Next Planned Date]) AS [Next PM in], 
    DATEDIFF(DAY, GETDATE(), mcl.[Finishing Date]) AS [Line Expiring in], 
    DATEDIFF(DAY, GETDATE(), pmch.[Finishing Date]) AS [Contract Expiring in], 
    EO.[Manufacturer Code], 
    EO.No_ AS [Equipment Object], 
    EO.[Equipment Category], 
    EO.[Equipment Model], 
    EO.[Serial No_] AS SerialNo, 
    EO.[Fleet Code] AS FleetCode,
    CAST(mcl.[Annual Amount] AS DECIMAL(38,2)) AS [FM Annual], 
    CAST(mcl.[Annual Amount] / 12 AS DECIMAL(38,2)) AS [Monthly Amount],
    pmch.[Bill-to Customer No_], 
    pmch.[Bill-to Name], 
    pmch.[Bill-to Address], 
    pmch.[Bill-to City],
    
    sao.[Job Code]  
FROM [Production$Equipment Object] EO 
LEFT JOIN [Production$Maintenance Contract Line] mcl 
    ON mcl.[Document No_] = EO.[Maintenance Contract] 
    AND mcl.[Equipment Object] = EO.No_ 
    AND mcl.Status IN (0,1) 
LEFT JOIN [Production$Maintenance Contract Header] pmch 
    ON mcl.[Document No_] = pmch.No_ 
LEFT JOIN [Production$Service Action Object] sao 
    ON EO.No_ = sao.[Equipment Object] 
    AND sao.[Job Code] LIKE '%PM%' 
LEFT JOIN [Production$Customer] c 
    ON EO.[Customer No_] = c.No_ 
LEFT JOIN [Production$Salesperson_Purchaser] sp 
    ON sp.Code = c.[Salesperson Service] 
LEFT JOIN [Production$Salesperson_Purchaser] sp1 
    ON sp1.Code = pmch.[Order Manager] 
WHERE EO.[Contract Type] NOT IN ('RPM', 'RPO', 'USEDRENTPM')  
    AND EO.[Posting Status] <> '2'  -- Not Stock 
    AND pmch.[No_] IS NOT NULL --
    and pmch.[Status]  in ('0','1')
    --AND pmch.[Contract Type] = 'BRONZE'
    --AND sp.[Name] = 'Mike Rentz'
    and sao.[Job Code] LIKE '%PM%'
       -- sao.[Job Code] = '')
   -- and pmch.[No_] = 'MC034047'
ORDER BY 
    mcl.[Document No_], 
    EO.No_;