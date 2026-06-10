 ----------------------------------------AVG of last 3 Meter Reading----------------------------------
---
WITH RankedReadings AS (
    SELECT  
        RCH.[Responsibility Center] as CSC,
        RCH.[No_],
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Fleet Code],
        Meter_Reading.[Meter],
        Equipment_Object.[Status],
        --Equipment_Object.[Posting Status],
        RCH.[Contract Type],
        RCL.[Starting Datetime] ,
        CAST(Meter_Reading.[DateTime] AS Date) AS Reading_Date,
        
        Format(CAST(Meter_Reading.Reading  AS DECIMAL(18,2)), '0.##') AS Meter_Reading,

        ROW_NUMBER() OVER (
            PARTITION BY Equipment_Object.[Customer No_], 
                         Equipment_Object.[Maintenance Contract], 
                         Equipment_Object.No_
            ORDER BY Meter_Reading.DateTime DESC
        ) AS rn
    FROM 
        [Production$Equipment Object] AS Equipment_Object
    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_
    left join [Production$Rental Contract Line] as RCL
    on Equipment_Object.No_ = RCL.[Equipment Object]
    LEFT JOIN [Production$Rental Contract Header] RCH
    on RCH.[No_] = RCL.[Document No_]
   
    --LEFT JOIN [Production$Customer] AS Customer 
      --  ON Equipment_Object.[Customer No_] = Customer.No_
    WHERE Meter_Reading.[Meter] = 1 and RCL.[Finishing Date Fixed] = '0' 
    --AND   RCH.[No_] = 'RO-039998' 
    AND RCL.[Starting Datetime] <= Meter_Reading.[DateTime]
    and Equipment_Object.[Equipment Category] <> 'BATTERY/CHARGER' AND RCH.[No_] not like 'RQ%'
    --ORDER BY  RCH.[No_]
),
First3Readings AS (
    SELECT *
    FROM RankedReadings
    WHERE rn <= 3
),
Averaged AS (
    SELECT 
        EquipmentObject,
        FORMAT(AVG(CAST(Meter_Reading AS DECIMAL(18,2))), '0.##') AS AvgLast3Readings
    FROM First3Readings 
    
    GROUP BY EquipmentObject
)
SELECT 
    F3.*,
    A.AvgLast3Readings
FROM 
    First3Readings F3
LEFT JOIN 
    Averaged A
    ON F3.EquipmentObject = A.EquipmentObject
WHERE 
    F3.[Status] IN ('RENTAL','USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX') 




----FINAL QUERY 

WITH RankedReadings AS (
    SELECT  
        RCH.[Responsibility Center] as CSC,
        RCH.[No_],
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Equipment Category],
        Equipment_Object.[Status],
        Equipment_Object.[Fleet Code],
        Equipment_Object.[Rent Allowable Hours],
        Meter_Reading.[Meter],
       -- Equipment_Object.[Status],
        RCH.[Contract Type],
        RCL.[Starting Datetime],
        CAST(Meter_Reading.[DateTime] AS Date) AS Reading_Date,
        CAST(Meter_Reading.Reading AS DECIMAL(18,2)) AS Meter_Reading,
        ROW_NUMBER() OVER (
            PARTITION BY Equipment_Object.[Customer No_], 
                         Equipment_Object.[Maintenance Contract], 
                         Equipment_Object.No_
            ORDER BY Meter_Reading.DateTime DESC
        ) AS rn
    FROM 
        [Production$Equipment Object] AS Equipment_Object
    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_
    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]
    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]
    WHERE 
        Meter_Reading.[Meter] = 1
        --AND RCL.[Finishing Date Fixed] = '0' 
        --AND RCL.[Starting Datetime] <= Meter_Reading.[DateTime]
        --AND Equipment_Object.[Status] in ('USEDONRENT','RENTAL')
        AND Equipment_Object.[Equipment Category] <> 'BATTERY/CHARGER'
        --AND RCH.[No_] NOT LIKE 'RQ%' 
        --AND RCH.[No_] = 'RO-040359' 
),
First3Readings AS (
    SELECT *
    FROM RankedReadings
    WHERE rn <= 3
),
Averaged AS (
    SELECT 
        EquipmentObject,
        FORMAT(AVG(Meter_Reading), '0.##') AS AvgLast3Readings
    FROM First3Readings 
    GROUP BY EquipmentObject
)
SELECT DISTINCT
    F3.CSC,
    F3.[No_],
    F3.CustomerNo_,
    F3.CustomerName,
    F3.[Sell-to Address],
    F3.MaintenanceContract,
    F3.EquipmentObject,
    F3.[Equipment Model],
    F3.[Equipment Category],
    F3.[Fleet Code],
    F3.[Rent Allowable Hours],
    F3.[Meter],
    F3.[Status],
    F3.[Contract Type],
    F3.[Starting Datetime],
    --FORMAT(F3.Meter_Reading, '0.##') AS Meter_Reading,
    A.AvgLast3Readings
FROM 
    First3Readings F3
LEFT JOIN 
    Averaged A
    ON F3.EquipmentObject = A.EquipmentObject
WHERE 
    F3.[Status] IN ('RENTAL', 'USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX') 
    --AND F3.[Rent Allowable Hours] <> 0



----meter readings table
WITH RankedReadings AS (
    SELECT  
        RCH.[Responsibility Center] as CSC,
        RCH.[No_],
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Fleet Code],
        Meter_Reading.[Meter],
        Equipment_Object.[Status],
        RCH.[Contract Type],
        RCL.[Starting Datetime],
        CAST(Meter_Reading.[DateTime] AS Date) AS Reading_Date,
        CAST(Meter_Reading.Reading AS DECIMAL(18,2)) AS Meter_Reading,
        ROW_NUMBER() OVER (
            PARTITION BY Equipment_Object.[Customer No_], 
                         Equipment_Object.[Maintenance Contract], 
                         Equipment_Object.No_
            ORDER BY Meter_Reading.DateTime DESC
        ) AS rn
    FROM 
        [Production$Equipment Object] AS Equipment_Object
    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_
    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]
    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]
    WHERE 
        --Meter_Reading.[Meter] = 1
         RCL.[Finishing Date Fixed] = '0' 
        AND RCL.[Starting Datetime] <= Meter_Reading.[DateTime]
        AND Equipment_Object.[Equipment Category] <> 'BATTERY/CHARGER'
        AND RCH.[No_] NOT LIKE 'RQ%' 
        and RCH.[No_] = 'RO-040359'
),
First3Readings AS (
    SELECT *
    FROM RankedReadings
    WHERE rn <= 3
),
Averaged AS (
    SELECT 
        EquipmentObject,
        FORMAT(AVG(Meter_Reading), '0.##') AS AvgLast3Readings
    FROM First3Readings 
    GROUP BY EquipmentObject
)
SELECT DISTINCT
    --F3.CSC,
    F3.[No_],
    --F3.CustomerNo_,
    --F3.CustomerName,
    --F3.[Sell-to Address],
    F3.MaintenanceContract,
    F3.EquipmentObject,
    --F3.[Equipment Model],
    --F3.[Fleet Code],
   F3.[Meter],
    --F3.[Status],
    --F3.[Contract Type],
    F3.[Starting Datetime],
    F3.[Reading_Date],
    FORMAT(F3.Meter_Reading, '0.##') AS Meter_Reading
    --A.AvgLast3Readings
FROM 
    First3Readings F3
LEFT JOIN 
    Averaged A
    ON F3.EquipmentObject = A.EquipmentObject
WHERE 
    F3.[Status] IN ('RENTAL', 'USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX')



----

---- Updated for actual meter readings on contract and average per day 

WITH RankedReadings AS (
    SELECT  
        RCH.[Responsibility Center] as CSC,
        RCH.[No_] AS ContractNo,
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Fleet Code],
        Meter_Reading.[Meter],
        case when Meter_Reading.[Meter] = '1' then 'Key Hours'
        when Meter_Reading.[Meter] ='2' then 'Pump Hours'
        when Meter_Reading.[Meter] ='3' then 'Drive Hours'
        else 'UK' END AS [Meter Type],
        Equipment_Object.[Status],
        RCH.[Contract Type],
        RCL.[Starting Datetime] AS StartDate,
        CAST(Meter_Reading.[DateTime] AS DATE) AS ReadingDate,
        CAST(Meter_Reading.Reading AS DECIMAL(18,2)) AS MeterReading,
        ROW_NUMBER() OVER (
            PARTITION BY Equipment_Object.No_
            ORDER BY Meter_Reading.DateTime ASC
        ) AS RowAsc,
        ROW_NUMBER() OVER (
            PARTITION BY Equipment_Object.No_
            ORDER BY Meter_Reading.DateTime DESC
        ) AS RowDesc
    FROM 
        [Production$Equipment Object] AS Equipment_Object
    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_
    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]
    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]
    WHERE 
        --Meter_Reading.[Meter] = 1
     --RCL.[Finishing Date Fixed] = '0' 
        --AND RCL.[Starting Datetime] <= Meter_Reading.[DateTime]
         Equipment_Object.[Equipment Category] <> 'BATTERY/CHARGER'
        --AND RCH.[No_] NOT LIKE 'RQ%' 
        and RCH.[No_]='RO-040359'
),
FirstReading AS (
    SELECT 
        EquipmentObject,
        MIN(ReadingDate) AS FirstReadingDate,
        MIN(MeterReading) AS FirstReadingValue
    FROM RankedReadings
    GROUP BY EquipmentObject
),
LastReading AS (
    SELECT 
        EquipmentObject,
        MAX(ReadingDate) AS LastReadingDate,
        MAX(MeterReading) AS LastReadingValue
    FROM RankedReadings
    GROUP BY EquipmentObject
),
Joined AS (
    SELECT 
        RR.CSC,
        RR.ContractNo,
        RR.CustomerNo_,
        RR.CustomerName,
        RR.[Sell-to Address],
        RR.MaintenanceContract,
        RR.EquipmentObject,
        RR.[Equipment Model],
        RR.[Fleet Code],
        RR.[Meter],
        RR.[Meter Type],
        RR.[Status],
        RR.[Contract Type],
        RR.StartDate,
        FR.FirstReadingDate,
        FR.FirstReadingValue,
        LR.LastReadingDate,
        LR.LastReadingValue,
        (LR.LastReadingValue - FR.FirstReadingValue) AS ReadingDifference,
        DATEDIFF(DAY, FR.FirstReadingDate, LR.LastReadingDate) AS DaysBetween,
        CASE 
            WHEN DATEDIFF(DAY, FR.FirstReadingDate, LR.LastReadingDate) > 0 
            THEN ROUND((LR.LastReadingValue - FR.FirstReadingValue) / NULLIF(DATEDIFF(DAY, FR.FirstReadingDate, LR.LastReadingDate), 0), 2)
            ELSE NULL 
        END AS AvgDailyUsage
    FROM 
        FirstReading FR
    JOIN LastReading LR
        ON FR.EquipmentObject = LR.EquipmentObject
    JOIN (
        SELECT DISTINCT EquipmentObject, CSC, ContractNo, CustomerNo_, CustomerName, [Sell-to Address], MaintenanceContract,
               [Equipment Model], [Fleet Code], [Meter], [Meter Type], [Status], [Contract Type], StartDate
        FROM RankedReadings
    ) RR ON RR.EquipmentObject = FR.EquipmentObject
)
SELECT *
FROM Joined
WHERE [Status] IN ('RENTAL','USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX');





------------------------------------- modified final with electric and regular differentiated ------------------------------------------


WITH RankedReadings AS (
    SELECT  
        RCH.[Responsibility Center] AS CSC,
        RCH.[No_] AS ContractNo,
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Fleet Code],
        Meter_Reading.[Meter],
        CASE 
            WHEN Meter_Reading.[Meter] = '1' THEN 'Key Hours'
            WHEN Meter_Reading.[Meter] = '2' THEN 'Pump Hours'
            WHEN Meter_Reading.[Meter] = '3' THEN 'Drive Hours'
            ELSE 'UK' 
        END AS [Meter Type],
        Equipment_Object.[Status],
        RCH.[Contract Type],
        RCL.[Starting Datetime] AS StartDate,
        CAST(Meter_Reading.[DateTime] AS DATE) AS ReadingDate,
        CAST(Meter_Reading.Reading AS DECIMAL(18,2)) AS MeterReading
    FROM 
        [Production$Equipment Object] AS Equipment_Object
    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_
    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]
    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]
    WHERE 
        RCL.[Finishing Date Fixed] = '0' 
        AND RCL.[Starting Datetime] <= Meter_Reading.[DateTime]
        AND Equipment_Object.[Equipment Category] <> 'BATTERY/CHARGER'
        AND RCH.[No_] NOT LIKE 'RQ%' 
        AND RCH.[No_] = 'RO-040359'
),
FilteredReadings AS (
    SELECT * FROM RankedReadings
    WHERE [Meter] IN (1, 2, 3)
),
FirstReading AS (
    SELECT 
        EquipmentObject,
        MIN(CASE WHEN [Meter] = 1 AND EquipmentObject NOT LIKE 'H%' THEN ReadingDate END) AS FirstKeyDate,
        MIN(CASE WHEN [Meter] = 1 AND EquipmentObject NOT LIKE 'H%' THEN MeterReading END) AS FirstKeyValue,

        MIN(CASE WHEN [Meter] = 2 AND EquipmentObject LIKE 'H%' THEN ReadingDate END) AS FirstPumpDate,
        MIN(CASE WHEN [Meter] = 2 AND EquipmentObject LIKE 'H%' THEN MeterReading END) AS FirstPumpValue,

        MIN(CASE WHEN [Meter] = 3 AND EquipmentObject LIKE 'H%' THEN ReadingDate END) AS FirstDriveDate,
        MIN(CASE WHEN [Meter] = 3 AND EquipmentObject LIKE 'H%' THEN MeterReading END) AS FirstDriveValue
    FROM FilteredReadings
    GROUP BY EquipmentObject
),
LastReading AS (
    SELECT 
        EquipmentObject,
        MAX(CASE WHEN [Meter] = 1 AND EquipmentObject NOT LIKE 'H%' THEN ReadingDate END) AS LastKeyDate,
        MAX(CASE WHEN [Meter] = 1 AND EquipmentObject NOT LIKE 'H%' THEN MeterReading END) AS LastKeyValue,

        MAX(CASE WHEN [Meter] = 2 AND EquipmentObject LIKE 'H%' THEN ReadingDate END) AS LastPumpDate,
        MAX(CASE WHEN [Meter] = 2 AND EquipmentObject LIKE 'H%' THEN MeterReading END) AS LastPumpValue,

        MAX(CASE WHEN [Meter] = 3 AND EquipmentObject LIKE 'H%' THEN ReadingDate END) AS LastDriveDate,
        MAX(CASE WHEN [Meter] = 3 AND EquipmentObject LIKE 'H%' THEN MeterReading END) AS LastDriveValue
    FROM FilteredReadings
    GROUP BY EquipmentObject
),
Joined AS (
    SELECT 
        RR.CSC,
        RR.ContractNo,
        RR.CustomerNo_,
        RR.CustomerName,
        RR.[Sell-to Address],
        RR.MaintenanceContract,
        RR.EquipmentObject,
        RR.[Equipment Model],
        RR.[Fleet Code],
        RR.[Meter],
        RR.[Meter Type],
        RR.[Status],
        RR.[Contract Type],
        RR.StartDate,

        -- Derived values depending on EquipmentObject prefix
        CASE 
            WHEN RR.EquipmentObject LIKE 'H%' 
                THEN COALESCE(FR.FirstPumpDate, FR.FirstDriveDate)
            ELSE FR.FirstKeyDate 
        END AS FirstReadingDate,

        CASE 
            WHEN RR.EquipmentObject LIKE 'H%' 
                THEN COALESCE(FR.FirstPumpValue, 0) + COALESCE(FR.FirstDriveValue, 0)
            ELSE FR.FirstKeyValue 
        END AS FirstReadingValue,

        CASE 
            WHEN RR.EquipmentObject LIKE 'H%' 
                THEN COALESCE(LR.LastPumpDate, LR.LastDriveDate)
            ELSE LR.LastKeyDate 
        END AS LastReadingDate,

        CASE 
            WHEN RR.EquipmentObject LIKE 'H%' 
                THEN COALESCE(LR.LastPumpValue, 0) + COALESCE(LR.LastDriveValue, 0)
            ELSE LR.LastKeyValue 
        END AS LastReadingValue,

        -- Difference and derived metric
        ( 
            CASE 
                WHEN RR.EquipmentObject LIKE 'H%' 
                    THEN COALESCE(LR.LastPumpValue, 0) + COALESCE(LR.LastDriveValue, 0)
                         - (COALESCE(FR.FirstPumpValue, 0) + COALESCE(FR.FirstDriveValue, 0))
                ELSE LR.LastKeyValue - FR.FirstKeyValue 
            END
        ) AS ReadingDifference,

        DATEDIFF(
            DAY, 
            CASE 
                WHEN RR.EquipmentObject LIKE 'H%' 
                    THEN COALESCE(FR.FirstPumpDate, FR.FirstDriveDate)
                ELSE FR.FirstKeyDate
            END,
            CASE 
                WHEN RR.EquipmentObject LIKE 'H%' 
                    THEN COALESCE(LR.LastPumpDate, LR.LastDriveDate)
                ELSE LR.LastKeyDate
            END
        ) AS DaysBetween,

        CASE 
            WHEN 
                DATEDIFF(
                    DAY, 
                    CASE 
                        WHEN RR.EquipmentObject LIKE 'H%' 
                            THEN COALESCE(FR.FirstPumpDate, FR.FirstDriveDate)
                        ELSE FR.FirstKeyDate
                    END,
                    CASE 
                        WHEN RR.EquipmentObject LIKE 'H%' 
                            THEN COALESCE(LR.LastPumpDate, LR.LastDriveDate)
                        ELSE LR.LastKeyDate
                    END
                ) > 0 
            THEN ROUND(
                (
                    CASE 
                        WHEN RR.EquipmentObject LIKE 'H%' 
                            THEN COALESCE(LR.LastPumpValue, 0) + COALESCE(LR.LastDriveValue, 0)
                                 - (COALESCE(FR.FirstPumpValue, 0) + COALESCE(FR.FirstDriveValue, 0))
                        ELSE LR.LastKeyValue - FR.FirstKeyValue 
                    END
                ) / 
                NULLIF(
                    DATEDIFF(
                        DAY, 
                        CASE 
                            WHEN RR.EquipmentObject LIKE 'H%' 
                                THEN COALESCE(FR.FirstPumpDate, FR.FirstDriveDate)
                            ELSE FR.FirstKeyDate
                        END,
                        CASE 
                            WHEN RR.EquipmentObject LIKE 'H%' 
                                THEN COALESCE(LR.LastPumpDate, LR.LastDriveDate)
                            ELSE LR.LastKeyDate
                        END
                    ), 0
                ), 2)
            ELSE NULL 
        END AS AvgDailyUsage

    FROM 
        FirstReading FR
    JOIN LastReading LR ON FR.EquipmentObject = LR.EquipmentObject
    JOIN (
        SELECT DISTINCT 
            EquipmentObject, CSC, ContractNo, CustomerNo_, CustomerName, [Sell-to Address], MaintenanceContract,
            [Equipment Model], [Fleet Code], [Meter], [Meter Type], [Status], [Contract Type], StartDate
        FROM FilteredReadings
    ) RR ON RR.EquipmentObject = FR.EquipmentObject
)
SELECT *
FROM Joined
WHERE [Status] IN ('RENTAL','USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX');



---
------ July 23 uPDted query ------

WITH RankedReadings AS (
    SELECT  
        RCH.[Responsibility Center] AS CSC,
        RCH.[No_],
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Fleet Code],
        Meter_Reading.[Meter],
        Equipment_Object.[Status],
        Equipment_Object.[Posting Status],
        Equipment_Object.[Contract Type],
        CAST(Meter_Reading.[DateTime] AS DATE) AS Reading_Date,
        FORMAT(CAST(Meter_Reading.Reading AS DECIMAL(18,2)), '0.##') AS Meter_Reading,

        ROW_NUMBER() OVER (
            PARTITION BY 
                Equipment_Object.[Customer No_], 
                Equipment_Object.[Maintenance Contract], 
                Equipment_Object.No_
            ORDER BY Meter_Reading.DateTime DESC
        ) AS rn

    FROM [Production$Equipment Object] AS Equipment_Object

    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_

    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]

    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]

    -- Optional: Uncomment if customer data needed
    -- LEFT JOIN [Production$Customer] AS Customer 
    --     ON Equipment_Object.[Customer No_] = Customer.No_

    WHERE Meter_Reading.[Meter] = 1
),

First3Readings AS (
    SELECT *
    FROM RankedReadings
    WHERE rn <= 3
),

Averaged AS (
    SELECT 
        EquipmentObject,
        FORMAT(AVG(CAST(Meter_Reading AS DECIMAL(18,2))), '0.##') AS AvgLast3Readings
    FROM First3Readings
    GROUP BY EquipmentObject
)

SELECT 
    F3.*,
    A.AvgLast3Readings
FROM First3Readings F3
LEFT JOIN Averaged A
    ON F3.EquipmentObject = A.EquipmentObject
WHERE 
    F3.[Status] IN ('RENTAL', 'USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX');

---updated average rental ot > 160 hrs
WITH RankedReadings AS (
    SELECT  
        RCH.[Responsibility Center] AS CSC,
        RCH.[No_],
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Fleet Code],
        Meter_Reading.[Meter],
        Equipment_Object.[Status],
        Equipment_Object.[Posting Status],
        Equipment_Object.[Contract Type],
        CAST(Meter_Reading.[DateTime] AS DATE) AS Reading_Date,
        CAST(Meter_Reading.Reading AS DECIMAL(18,2)) AS Meter_Reading,

        ROW_NUMBER() OVER (
            PARTITION BY 
                Equipment_Object.[Customer No_], 
                Equipment_Object.[Maintenance Contract], 
                Equipment_Object.No_
            ORDER BY Meter_Reading.DateTime DESC
        ) AS rn

    FROM [Production$Equipment Object] AS Equipment_Object

    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_

    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]

    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]

    WHERE Meter_Reading.[Meter] = 1
),

First3Readings AS (
    SELECT *
    FROM RankedReadings
    WHERE rn <= 3
),

Pivoted AS (
    SELECT
        EquipmentObject,
        MAX(CASE WHEN rn = 1 THEN Reading_Date END) AS LatestDate,
        MAX(CASE WHEN rn = 3 THEN Reading_Date END) AS ThirdDate,
        MAX(CASE WHEN rn = 1 THEN Meter_Reading END) AS LatestReading,
        MAX(CASE WHEN rn = 3 THEN Meter_Reading END) AS ThirdReading
    FROM First3Readings
    GROUP BY EquipmentObject
),

Computed AS (
    SELECT
        P.EquipmentObject,
        DATEDIFF(DAY, ThirdDate, LatestDate) AS ReadingDateDifference_Days,
        ROUND(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 2) AS ReadingDateDifference_Months,
        LatestReading - ThirdReading AS ReadingDifference,
        ROUND((LatestReading - ThirdReading) / NULLIF(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 0), 2) AS AvgMonthlyReading_Hours,
        160 AS AllowedHoursPerMonth,
        CASE 
            WHEN (LatestReading - ThirdReading) / NULLIF(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 0) > 160 THEN 'Yes'
            ELSE 'No'
        END AS IsAboveAllowedHours
    FROM Pivoted P
)

SELECT 
    F3.*,
    C.ReadingDateDifference_Days,
    C.ReadingDateDifference_Months,
    C.ReadingDifference,
    C.AvgMonthlyReading_Hours,
    C.AllowedHoursPerMonth,
    C.IsAboveAllowedHours
FROM First3Readings F3
LEFT JOIN Computed C
    ON F3.EquipmentObject = C.EquipmentObject
WHERE 
    F3.[Status] IN ('RENTAL', 'USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX');

-------xxxxxxxxxxxxxxxxxxxxxxxxxfnal modified with electric objects with flags of OT xxxxxxxxxxxxx-----------------------------

WITH EquipmentWithDriveType AS (
    SELECT  
        RCH.[Responsibility Center] AS CSC,
        RCH.[No_] AS RentalContractNo,
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model] AS EquipmentModel,
        CASE
            WHEN CHARINDEX('B', Equipment_Object.[Equipment Model]) > 0 THEN 'Electric'
            WHEN CHARINDEX('G', Equipment_Object.[Equipment Model]) > 0 THEN 'Gasoline'
            WHEN CHARINDEX('D', Equipment_Object.[Equipment Model]) > 0 THEN 'Diesel'
            WHEN CHARINDEX('W', Equipment_Object.[Equipment Model]) > 0 THEN 'Walkie'
            WHEN CHARINDEX('N', Equipment_Object.[Equipment Model]) > 0 THEN 'Narrow Chassis'
            ELSE 'Other'
        END AS DriveType,
        Equipment_Object.[Fleet Code] AS FleetCode,
        Meter_Reading.[Meter],
        Equipment_Object.[Status],
        Equipment_Object.[Posting Status],
        Equipment_Object.[Contract Type],
        CAST(Meter_Reading.[DateTime] AS DATE) AS Reading_Date,
        CAST(Meter_Reading.Reading AS DECIMAL(18,2)) AS Meter_Reading
    FROM [Production$Equipment Object] AS Equipment_Object
    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_
    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]
    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]
    WHERE Meter_Reading.[Meter] IN (1, 2, 3)
),
RankedReadings AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EquipmentObject, Meter
            ORDER BY Reading_Date DESC
        ) AS rn
    FROM EquipmentWithDriveType
),
LatestElectricReadings AS (
    SELECT 
        EquipmentObject,
        MAX(CASE WHEN Meter = 1 AND rn = 1 THEN Meter_Reading END) AS M1_Latest,
        MAX(CASE WHEN Meter = 2 AND rn = 1 THEN Meter_Reading END) AS M2_Latest,
        MAX(CASE WHEN Meter = 3 AND rn = 1 THEN Meter_Reading END) AS M3_Latest,
        MAX(CASE WHEN Meter = 1 AND rn = 1 THEN Reading_Date END) AS M1_Latest_Date,
        MAX(CASE WHEN Meter IN (2,3) AND rn = 1 THEN Reading_Date END) AS M23_Latest_Date
    FROM RankedReadings
    GROUP BY EquipmentObject
),
ThirdElectricReadings AS (
    SELECT 
        EquipmentObject,
        MAX(CASE WHEN Meter = 1 AND rn = 3 THEN Meter_Reading END) AS M1_Third,
        MAX(CASE WHEN Meter = 2 AND rn = 3 THEN Meter_Reading END) AS M2_Third,
        MAX(CASE WHEN Meter = 3 AND rn = 3 THEN Meter_Reading END) AS M3_Third,
        MAX(CASE WHEN Meter = 1 AND rn = 3 THEN Reading_Date END) AS M1_Third_Date,
        MAX(CASE WHEN Meter IN (2,3) AND rn = 3 THEN Reading_Date END) AS M23_Third_Date
    FROM RankedReadings
    GROUP BY EquipmentObject
),
ElectricAdjusted AS (
    SELECT 
        L.EquipmentObject,
        CASE 
            WHEN E.DriveType = 'Electric' THEN 
                (SELECT MIN(val) FROM (VALUES (ISNULL(L.M1_Latest, 0)), (ISNULL(L.M2_Latest, 0) + ISNULL(L.M3_Latest, 0))) AS ValueTable(val))
            ELSE ISNULL(L.M1_Latest, 0)
        END AS LatestReading,
        CASE 
            WHEN E.DriveType = 'Electric' THEN 
                (SELECT MIN(val) FROM (VALUES (ISNULL(T.M1_Third, 0)), (ISNULL(T.M2_Third, 0) + ISNULL(T.M3_Third, 0))) AS ValueTable(val))
            ELSE ISNULL(T.M1_Third, 0)
        END AS ThirdReading,
        CASE 
            WHEN E.DriveType = 'Electric' THEN 
                COALESCE(L.M23_Latest_Date, L.M1_Latest_Date)
            ELSE L.M1_Latest_Date
        END AS LatestDate,
        CASE 
            WHEN E.DriveType = 'Electric' THEN 
                COALESCE(T.M23_Third_Date, T.M1_Third_Date)
            ELSE T.M1_Third_Date
        END AS ThirdDate,
        E.DriveType,
        E.EquipmentModel,
        E.CSC,
        E.CustomerNo_,
        E.CustomerName,
        E.[Sell-to Address],
        E.MaintenanceContract,
        E.FleetCode,
        E.Status,
        E.[Posting Status],
        E.[Contract Type]
    FROM LatestElectricReadings L
    INNER JOIN ThirdElectricReadings T ON L.EquipmentObject = T.EquipmentObject
    INNER JOIN (
        SELECT DISTINCT 
            EquipmentObject, DriveType, EquipmentModel, CSC, CustomerNo_, CustomerName, [Sell-to Address], 
            MaintenanceContract, FleetCode, [Status], [Posting Status], [Contract Type] 
        FROM EquipmentWithDriveType
    ) E ON E.EquipmentObject = L.EquipmentObject
),
Computed AS (
    SELECT
        *,
        DATEDIFF(DAY, ThirdDate, LatestDate) AS ReadingDateDifference_Days,
        ROUND(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 2) AS ReadingDateDifference_Months,
        LatestReading - ThirdReading AS ReadingDifference,
        ROUND((LatestReading - ThirdReading) / NULLIF(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 0), 2) AS AvgMonthlyReading_Hours,
        160 AS AllowedHoursPerMonth,
        CASE 
            WHEN ROUND((LatestReading - ThirdReading) / NULLIF(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 0), 2) > 160 THEN 'Yes'
            ELSE 'No'
        END AS IsAboveAllowedHours
    FROM ElectricAdjusted
)
SELECT *
FROM Computed
WHERE Status IN ('RENTAL', 'USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX');


----xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  final jul 24 single record for each EO xxxxxxxxxxxxxxxxxxxxxxxxxxxx---------------------------------

WITH RankedReadings AS (
    SELECT  
        --RCH.[Responsibility Center] AS CSC,
        RCH.[No_],
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        Equipment_Object.[Responsibility Center] as CSC,
        Equipment_Object.No_ AS EquipmentObject,
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Fleet Code],
        Meter_Reading.[Meter],
        Equipment_Object.[Status],
        Equipment_Object.[Posting Status],
        Equipment_Object.[Contract Type],
        CAST(Meter_Reading.[DateTime] AS DATE) AS Reading_Date,
        CAST(Meter_Reading.Reading AS DECIMAL(18,2)) AS Meter_Reading,

        ROW_NUMBER() OVER (
            PARTITION BY 
                Equipment_Object.[Customer No_], 
                Equipment_Object.[Maintenance Contract], 
                Equipment_Object.No_
            ORDER BY Meter_Reading.DateTime DESC
        ) AS rn

    FROM [Production$Equipment Object] AS Equipment_Object

    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_

    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]

    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]

    WHERE Meter_Reading.[Meter] = 1
),

First3Readings AS (
    SELECT *
    FROM RankedReadings
    WHERE rn <= 3
),

Pivoted AS (
    SELECT
        MAX(CSC) AS CSC,
        MAX(CustomerNo_) AS CustomerNo_,
        MAX(CustomerName) AS CustomerName,
        MAX([Sell-to Address]) AS [Sell-to Address],
        MAX(MaintenanceContract) AS MaintenanceContract,
        MAX([Equipment Model]) AS [Equipment Model],
        MAX([Fleet Code]) AS [Fleet Code],
        MAX([Status]) AS [Status],
        MAX([Posting Status]) AS [Posting Status],
        MAX([Contract Type]) AS [Contract Type],
        EquipmentObject,
        MAX(CASE WHEN rn = 1 THEN Reading_Date END) AS LatestDate,
        MAX(CASE WHEN rn = 3 THEN Reading_Date END) AS ThirdDate,
        MAX(CASE WHEN rn = 1 THEN Meter_Reading END) AS LatestReading,
        MAX(CASE WHEN rn = 3 THEN Meter_Reading END) AS ThirdReading
    FROM First3Readings
    GROUP BY EquipmentObject
),

Computed AS (
    SELECT
        P.EquipmentObject,
        P.CSC,
        P.CustomerNo_,
        P.CustomerName,
        P.[Sell-to Address],
        P.MaintenanceContract,
        P.[Equipment Model],
        P.[Fleet Code],
        P.[Status],
        P.[Posting Status],
        P.[Contract Type],
        P.LatestDate,
        P.ThirdDate,
        P.LatestReading,
        P.ThirdReading,
        DATEDIFF(DAY, ThirdDate, LatestDate) AS ReadingDateDifference_Days,
        ROUND(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 2) AS ReadingDateDifference_Months,
        LatestReading - ThirdReading AS ReadingDifference,
        ROUND((LatestReading - ThirdReading) / NULLIF(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 0), 2) AS AvgMonthlyReading_Hours,
        160 AS AllowedHoursPerMonth,
        CASE 
            WHEN (LatestReading - ThirdReading) / NULLIF(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 0) > 160 THEN 'Yes'
            ELSE 'No'
        END AS IsAboveAllowedHours
    FROM Pivoted P
)

SELECT *
FROM Computed
WHERE [Status] IN ('RENTAL', 'USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX');

---test----
select top 1000 * from [Production$Meter Reading]

-----

---
[Production$Rental Contract Line Periods]  --for allowed rent hours, rental contract period

 select [Posting Status], [Status] from [Production$Equipment Object] 
 where [No_] ='E055166'

 select
  distinct [Posting Status],
  [Status] from [Production$Equipment Object] 
 where [No_] ='E055166'


 select * from [Production$Meter Reading]
 where [Equipment Object] ='E092069' AND [Meter] = '1'

 order by [DateTime] DESC



 --- test rent utilization 
 select top 100 * from [Production$Rental Contract Line]



 ----Final query 

 WITH RankedReadings AS (
    SELECT 
        Equipment_Object.No_ AS EquipmentObject, 
        RCH.[No_],
        Equipment_Object.[Maintenance Contract] AS MaintenanceContract,
        RCH.[Sell-to Customer No_] AS CustomerNo_,
        RCH.[Sell-to Customer Name] AS CustomerName,
        RCH.[Sell-to Address],
        RCL.[Starting Date],
        RCL.[Finishing Date],
        Equipment_Object.[Responsibility Center] as CSC,
        Equipment_Object.[Rental Status],
        
        Equipment_Object.[Equipment Model],
        Equipment_Object.[Fleet Code],
        Meter_Reading.[Meter],
        Equipment_Object.[Status],
        Equipment_Object.[Posting Status],
        Equipment_Object.[Contract Type],
        CAST(Meter_Reading.[DateTime] AS DATE) AS Reading_Date,
        CAST(Meter_Reading.Reading AS DECIMAL(18,2)) AS Meter_Reading,
        Meter_Reading.[Source No_],

        ROW_NUMBER() OVER (
            PARTITION BY 
                Equipment_Object.[Customer No_], 
                RCH.[No_],
                Equipment_Object.[Maintenance Contract], 
                Equipment_Object.No_,
                Meter_Reading.[Source No_]
            ORDER BY Meter_Reading.DateTime DESC
        ) AS rn_source
    FROM [Production$Equipment Object] AS Equipment_Object
    LEFT JOIN [Production$Meter Reading] AS Meter_Reading
        ON Meter_Reading.[Equipment Object] = Equipment_Object.No_
    LEFT JOIN [Production$Rental Contract Line] AS RCL
        ON Equipment_Object.No_ = RCL.[Equipment Object]
    LEFT JOIN [Production$Rental Contract Header] AS RCH
        ON RCH.[No_] = RCL.[Document No_]
    WHERE Meter_Reading.[Meter] = 1 
    AND Equipment_Object.No_ = 'E168209' 
    AND [Ignore in calculations] = '0'
),

LatestPerSource AS (
    -- Pick only the most recent reading per Source No_
    SELECT *
    FROM RankedReadings
    WHERE rn_source = 1
),

RankedDistinctSources AS (
    -- Rank again across distinct Source No_ readings to get latest 3 overall
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY EquipmentObject
            ORDER BY Reading_Date DESC
        ) AS rn
    FROM LatestPerSource
),

First3Readings AS (
    SELECT *
    FROM RankedDistinctSources
    WHERE rn <= 3
),

Pivoted AS (
    SELECT
        [Rental Status],
        (No_) as [Rental Contract],
        CSC,
        CustomerNo_,
        CustomerName,
        [Sell-to Address],
        MaintenanceContract,
        --MAX([Equipment Model]) AS [Equipment Model],
        --MAX([Fleet Code]) AS [Fleet Code],
        [Status],
        [Posting Status],
        --MAX([Contract Type]) AS [Contract Type],
        EquipmentObject,
        MAX(CASE WHEN rn = 1 THEN Reading_Date END) AS LatestDate,
        MAX(CASE WHEN rn = 3 THEN Reading_Date END) AS ThirdDate,
        MAX(CASE WHEN rn = 1 THEN Meter_Reading END) AS LatestReading,
        MAX(CASE WHEN rn = 3 THEN Meter_Reading END) AS ThirdReading
    FROM First3Readings
    GROUP BY [Rental Status],
        (No_) ,
        CSC,
        CustomerNo_,
        CustomerName,
        [Sell-to Address],
        MaintenanceContract,
        --MAX([Equipment Model]) AS [Equipment Model],
        --MAX([Fleet Code]) AS [Fleet Code],
        [Status],
        [Posting Status],
        --MAX([Contract Type]) AS [Contract Type],
        EquipmentObject
),

Computed AS (
    SELECT
        P.EquipmentObject,
        P.[Rental Contract],
        P.[Rental Status],
        P.CSC,
        P.CustomerNo_,
        P.CustomerName,
        P.[Sell-to Address],
        P.MaintenanceContract,
        --P.[Equipment Model],
        --P.[Fleet Code],
        P.[Status],
        P.[Posting Status],
        --P.[Contract Type],
        P.LatestDate,
        P.ThirdDate,
        P.LatestReading,
        P.ThirdReading,
        DATEDIFF(DAY, ThirdDate, LatestDate) AS ReadingDateDifference_Days,
        ROUND(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 2) AS ReadingDateDifference_Months,
        LatestReading - ThirdReading AS ReadingDifference,
        ROUND((LatestReading - ThirdReading) / NULLIF(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 0), 2) AS AvgMonthlyReading_Hours,
        160 AS AllowedHoursPerMonth,
        CASE 
            WHEN (LatestReading - ThirdReading) / NULLIF(DATEDIFF(DAY, ThirdDate, LatestDate) / 30.0, 0) > 160 THEN 'Yes'
            ELSE 'No'
        END AS IsAboveAllowedHours
    FROM Pivoted P
)

SELECT *
FROM Computed
WHERE [Status] IN ('RENTAL', 'USEDONRENT', 'RENTED', 'RPO', 'ATR', 'USED', 'FLEX');


-----Customer Rentals updated for Rental OT

select 
rch.[Responsibility Center] as CSC
,c.[No_]
      ,c.[Name]
      ,c.[Name 2]
      ,c.[Address]
      ,c.[Address 2]
      ,c.[City]
      ,c.[Contact]
      ,c.[Phone No_]
      ,c.[Fax No_]
      ,c.[E-Mail] 
--rch.[Sell-to Customer No_],
--rch.[Sell-to Customer Name]
--,rch.[Sell-to Customer Name 2]
      --,rch.[Sell-to Address]
      --,rch.[Sell-to Address 2]
      --,rch.[Sell-to City]
      --,rch.[Sell-to Contact]
      
      ,rch.[Sell-to Post Code]
      ,rch.[Sell-to County]
      ,rch.[Sell-to Country Code] 
      ,rch.[No_] as [Document No_]
      ,rcl.[Equipment Group]
      ,rcl.[No_] as [Equipment Model]
      ,rcl.[Equipment Object] 
      ,MR.Reading
      ,MR.DateTime as [Reading Date]
      ,rch.[Contract Type]
      ,rcl.[Description]   
      --,cast(rcl.[Starting Date] as date) as [Starting Date]
      --,cast(rcl.[Starting Time] as time) as [Starting Time]
      --,cast(rcl.[Exp_ Return Date] as date) as [Exp_ Return Date]
      --,cast(rcl.[Return Time] as time) as [Return Time]
      --,rcl.[Starting Date Fixed]
      --,rcl.[Finishing Date Fixed]  ---0 = Active Rental, 1 =  
      ,-- Starting DateTime
-- Starting DateTime
cast(
    format(rcl.[Starting Date], 'yyyy-MM-dd') + ' ' + format(rcl.[Starting Time], 'HH:mm:ss')
    as datetime
) as [Starting DateTime],

-- Finishing Datetime
cast(
    format(rcl.[Finishing Date], 'yyyy-MM-dd') + ' ' + format(rcl.[Finishing Time], 'HH:mm:ss')
    as datetime
) as [Finishing DateTime]

-- Expected Return DateTime
--cast(
    --format(rcl.[Exp_ Return Date], 'yyyy-MM-dd') + ' ' + format(rcl.[Return Time], 'HH:mm:ss')
    --as datetime
--) as [Expected Return DateTime],

-- Estimated Rental Hours
--round(
   -- datediff(minute,
    --    cast(format(rcl.[Starting Date], 'yyyy-MM-dd') + ' ' + format(rcl.[Starting Time], 'HH:mm:ss') as datetime),
    --    cast(format(rcl.[Exp_ Return Date], 'yyyy-MM-dd') + ' ' + format(rcl.[Return Time], 'HH:mm:ss') as datetime)
    --) / (60.0*24), 2
--) as [Estimated Rental Days]

     
  from
  --[Production$Customer] c 
  --left Join 
  [Production$Rental Contract Header] rch  
  --ON  c.[No_] =  rch.[No_] and rch.[Status] = '1' 
  INNER JOIN [Production$Rental Contract Line] rcl 
 on rch.[No_] = rcl.[Document No_] and rch.[Sell-to Customer No_]=rcl.[Customer] 
 inner join [Production$Customer] c on  c.[No_] =  rch.[Sell-to Customer No_]
 LEFT JOIN [Production$Equipment Object] EO ON
 rcl.[Equipment Object] = EO.[No_]
 LEFT JOIN [Production$Meter Reading] AS MR
        ON MR.[Equipment Object] =EO.[No_]
 
 where 
 rch.[Status] = '2' --CLOSED
 and rcl.[Type] = '0' --RENT
 --and rcl.[Finishing Date Fixed] = '1' 
 AND rcl.[Equipment Object] = 'E168209'
  --and  rch.[Sell-to Customer No_] = '134700001'
order by 
      c.[Name]
      ,rch.[No_]
      ,rcl.[Equipment Object] 
      , rcl.[Starting Date]
      , rcl.[Starting Time]
      --, rcl.[Exp_ Return Date]
      --, rcl.[Return Time]

--test 
 select [Equipment Object],Reading, DateTime from [Production$Meter Reading]
 where [Equipment Object] = 'E168209' AND [Meter] = 1


--


      ---- test updated final rental ot 

WITH ContractPeriods AS (
    SELECT 
        rch.[Responsibility Center] AS CSC,
        c.[No_] AS Customer_No,
        c.[Name],
        c.[Name 2],
        c.[Address],
        c.[Address 2],
        c.[City],
        c.[Contact],
        c.[Phone No_],
        c.[Fax No_],
        c.[E-Mail],
        case when rch.[Status] = 0 then 'Open'
             when rch.[Status] = 1 then 'Released'
             when rch.[Status] = 2 then 'Closed'
             when rch.[Status] = 3 then 'Lost Order'
             else 'NA' END AS R_Contract_Status, 

        rch.[Sell-to Post Code],
        rch.[Sell-to County],
        rch.[Sell-to Country Code],
        rch.[No_] AS [Document No_],
        rcl.[Equipment Group],
        rcl.[No_] AS [Equipment Model],
        rcl.[Equipment Object],
        rch.[Contract Type],
        rcl.[Description],

        CAST(FORMAT(rcl.[Starting Date], 'yyyy-MM-dd') + ' ' + FORMAT(rcl.[Starting Time], 'HH:mm:ss') AS DATETIME) AS StartingDateTime,
        CAST(FORMAT(rcl.[Finishing Date], 'yyyy-MM-dd') + ' ' + FORMAT(rcl.[Finishing Time], 'HH:mm:ss') AS DATETIME) AS FinishingDateTime
    FROM 
        [Production$Rental Contract Header] rch
        INNER JOIN [Production$Rental Contract Line] rcl 
            ON rch.[No_] = rcl.[Document No_] 
           AND rch.[Sell-to Customer No_] = rcl.[Customer]
        INNER JOIN [Production$Customer] c 
            ON c.[No_] = rch.[Sell-to Customer No_]
    WHERE 
        rch.[Status] in ('1','2')  -- CLOSED
        AND rcl.[Type] = '0' -- RENT
        --AND rcl.[Equipment Object] = 'E168209'
),
FilteredReadings AS (
    SELECT 
        cp.*,
        MR.[Reading],
        CASE EO.[Rental Status]
    WHEN 0 THEN ''
    WHEN 1 THEN 'In'
    WHEN 2 THEN 'Out'
    WHEN 3 THEN 'Out Free'
    WHEN 4 THEN 'Not Rentable'
    WHEN 5 THEN 'Assigned'
    WHEN 6 THEN 'Out Assigned'
END AS RentalStatus
,
        MR.[DateTime] AS ReadingDate,
        ROW_NUMBER() OVER (PARTITION BY cp.[Document No_], cp.[Equipment Object] ORDER BY MR.[DateTime] DESC) AS rn
    FROM ContractPeriods cp
    LEFT JOIN [Production$Equipment Object] EO 
        ON cp.[Equipment Object] = EO.[No_]
    LEFT JOIN [Production$Meter Reading] MR
        ON MR.[Equipment Object] = EO.[No_]
       AND MR.[DateTime] BETWEEN cp.StartingDateTime AND cp.FinishingDateTime
    where MR.[Meter] = 1 and MR.[Ignore in calculations] = 0
),
PickedReadings AS (
    SELECT 
        fr.[Document No_],
        fr.[Equipment Object],
        fr.RentalStatus,
        MAX(CASE WHEN rn = 1 THEN ReadingDate END) AS LatestReadingDate,
        MAX(CASE WHEN rn = 1 THEN Reading END) AS LatestReading,
        MAX(CASE WHEN rn = 3 THEN ReadingDate END) AS ThirdLatestReadingDate,
        MAX(CASE WHEN rn = 3 THEN Reading END) AS ThirdLatestReading,
        MAX(CASE WHEN rn = 2 THEN ReadingDate END) AS SecondLatestReadingDate,
        MAX(CASE WHEN rn = 2 THEN Reading END) AS SecondLatestReading
    FROM FilteredReadings fr
    WHERE rn <= 3
    GROUP BY fr.[Document No_], fr.[Equipment Object],fr.RentalStatus
),
UsageCalc AS (
    SELECT 
        pr.[Document No_],
        pr.[Equipment Object],
        pr.RentalStatus,
        COALESCE(pr.ThirdLatestReadingDate, pr.SecondLatestReadingDate) AS StartReadingDate,
        COALESCE(pr.ThirdLatestReading, pr.SecondLatestReading) AS StartReading,
        pr.LatestReadingDate,
        pr.LatestReading,

        -- Months difference
        DATEDIFF(DAY, COALESCE(pr.ThirdLatestReadingDate, pr.SecondLatestReadingDate), pr.LatestReadingDate) / 30.0 AS DiffMonths,

        -- Reading difference
        (pr.LatestReading - COALESCE(pr.ThirdLatestReading, pr.SecondLatestReading)) AS DiffReading
    FROM PickedReadings pr
)
SELECT 
    cp.*,
    uc.RentalStatus,
    uc.StartReadingDate,
    uc.StartReading,
    uc.LatestReadingDate,
    uc.LatestReading,
    uc.DiffMonths,
    uc.DiffReading,
    CASE WHEN uc.DiffMonths > 0 THEN uc.DiffReading / uc.DiffMonths ELSE NULL END AS EstimatedUsagePerMonth,
    160 AS AllowedUsagePerMonth,
   CASE 
    WHEN uc.DiffMonths > 0 
         AND (uc.DiffReading / uc.DiffMonths) > 160 THEN 'Yes'
    WHEN uc.DiffMonths IS NULL 
         OR (uc.DiffReading / NULLIF(uc.DiffMonths, 0)) IS NULL THEN 'Not Sure'
    ELSE 'No'
END AS OverUsageFlag

FROM ContractPeriods cp
LEFT JOIN UsageCalc uc
    ON cp.[Document No_] = uc.[Document No_]
   AND cp.[Equipment Object] = uc.[Equipment Object]
--LEFT JOIN FilteredReadings FR ON cp.[Equipment Object] = FR.[Equipment Object]
--WHERE YEAR(cp.[StartingDateTime]) > 2024
ORDER BY cp.Name, cp.[Document No_], cp.[Equipment Object];

