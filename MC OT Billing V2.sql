WITH MaintContractLinePeriods AS (
    SELECT
        mclp.[Document No_],
        pmch.No_ AS MC,
        mclp.[Equipment Object],
        EO.[Equipment Category],
        EO.[Description],
        pmch.[Sell-to Customer No_],
        pmch.[Sell-to Customer Name],
        pmch.[Contract Type],

        MAX(mclp.[Period No_]) / 12 AS [Years of Contract],

        CASE
            WHEN DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) = 0
                THEN CAST(DATEDIFF(DAY, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) AS FLOAT)
                     / DAY(EOMONTH(MIN(mclp.[Starting Date])))
            ELSE DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date]))
        END AS [Contract Duration (Months)],

        mcl.[Starting Date] AS [MCL S date],
        mcl.[Finishing Date] AS [MCL F date],

        MIN(pmch.[Starting Date]) AS [Contract Start Date],
        MAX(pmch.[Finishing Date]) AS [Contract End Date],
        AVG(mclp.[M1 included per Year]) AS [Allowable Annual Hours],
        AVG(mclp.[Annual Amount]) AS [Annual Amount],
        AVG(mclp.[Monthly Amount]) AS [Monthly Amount],
        AVG(mclp.[Unit Price M1 Overtime Billing]) AS [OT Unit Price],
        SUM(mclp.[Amount Invoiced]) AS [Amount Invoiced],

        (
            AVG(mclp.[M1 included per Year] / 12) *
            CASE
                WHEN DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) = 0
                    THEN CAST(DATEDIFF(DAY, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) AS FLOAT)
                         / DAY(EOMONTH(MIN(mclp.[Starting Date])))
                ELSE DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date]))
            END
        ) AS [Total Allowable Hours]

    FROM [Copyofproduction].[dbo].[Production$Maint Contract Line Periods] mclp
    LEFT JOIN [Production$Equipment Object] EO
        ON mclp.[Equipment Object] = EO.[No_]
    LEFT JOIN [Production$Maintenance Contract Line] mcl
        ON mcl.[Document No_] = EO.[Maintenance Contract]
       AND mcl.[Equipment Object] = EO.No_
       AND mcl.Status IN (0, 1)
    LEFT JOIN [Production$Maintenance Contract Header] pmch
        ON mcl.[Document No_] = pmch.No_
       AND mclp.[Document No_] = pmch.No_
    WHERE pmch.[Status] IN ('1')
      AND pmch.[Contract Type] IN ('GOLD', 'PLATINUM', 'SILVER')
      AND pmch.[Document Status] NOT IN ('EXPIRED', 'CANCELLED')
      AND mcl.[Status] IN ('1')
      -- AND pmch.No_ = '003028'
      AND mclp.[M1 included per Year] <> 0
    GROUP BY
        mclp.[Document No_],
        pmch.No_,
        EO.[Description],
        mclp.[Equipment Object],
        pmch.[Sell-to Customer No_],
        pmch.[Sell-to Customer Name],
        mcl.[Starting Date],
        mcl.[Finishing Date],
        pmch.[Contract Type],
        EO.[Equipment Category]
),

/* Non-electric equipment: use Meter = 1 */
NonElectricMeterReadings AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.Reading AS FLOAT) AS ReadingValue
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] NOT IN ('CLASS I', 'CLASS II', 'CLASS III')
      AND mr.Meter = 1
),

/* Electric equipment: sum Meter 2 + Meter 3 for the same equipment and same day */
ElectricMeterReadings AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        MIN(mr.[DateTime]) AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(SUM(mr.Reading) AS FLOAT) AS ReadingValue
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] IN ('CLASS I', 'CLASS II', 'CLASS III')
      AND mr.Meter IN (2, 3)
    GROUP BY
        mr.[Equipment Object],
        eo.[Maintenance Contract],
        eo.[Equipment Category],
        CAST(mr.[DateTime] AS DATE)
),

/* Unified reading set */
MeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM NonElectricMeterReadings

    UNION ALL

    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM ElectricMeterReadings
),

UsageStats AS (
    SELECT
        mc.[Sell-to Customer No_],
        mc.[Sell-to Customer Name],
        mc.[Document No_] AS MaintenanceContract,
        mc.[Contract Type],
        mc.[Equipment Object] AS EquipmentObject,
        mc.[Equipment Category],
        mc.[Description],
        mc.[MCL S date],
        mc.[MCL F date],
        mc.[Contract Start Date],
        mc.[Contract End Date],
        mc.[Allowable Annual Hours],
        mc.[Annual Amount],
        mc.[Monthly Amount],
        mc.[Amount Invoiced],
        mc.[OT Unit Price],
        mc.[Total Allowable Hours],
        mc.[Contract Duration (Months)],

        oldr.OldestReading,
        oldr.OldestReadingDate,
        latestr.LatestReading,
        latestr.LatestReadingDate

    FROM MaintContractLinePeriods mc

    OUTER APPLY (
        SELECT TOP 1
            mr.ReadingValue AS OldestReading,
            mr.Reading_Date AS OldestReadingDate
        FROM MeterReadings mr
        WHERE mr.EquipmentObject = mc.[Equipment Object]
          AND mr.MaintenanceContract = mc.[Document No_]
          AND mr.Reading_Date >= mc.[MCL S date]
          AND mr.Reading_Date <= mc.[MCL F date]
        ORDER BY mr.Reading_Date ASC, mr.ReadingDateTime ASC
    ) oldr

    OUTER APPLY (
        SELECT TOP 1
            mr.ReadingValue AS LatestReading,
            mr.Reading_Date AS LatestReadingDate
        FROM MeterReadings mr
        WHERE mr.EquipmentObject = mc.[Equipment Object]
          AND mr.MaintenanceContract = mc.[Document No_]
          AND mr.Reading_Date >= mc.[MCL S date]
          AND mr.Reading_Date <= mc.[MCL F date]
        ORDER BY mr.Reading_Date DESC, mr.ReadingDateTime DESC
    ) latestr
),

FinalUsage AS (
    SELECT
        us.[Sell-to Customer No_],
        us.[Sell-to Customer Name],
        us.EquipmentObject,
        us.[Equipment Category],
        us.[Description],
        us.MaintenanceContract,
        us.[Contract Type],
        us.[MCL S date],
        us.[MCL F date],
        us.[Contract Start Date],
        us.[Contract End Date],
        us.[Allowable Annual Hours],
        us.[Annual Amount],
        us.[Monthly Amount],
        us.[Amount Invoiced],
        us.[OT Unit Price],
        us.[Total Allowable Hours],
        us.[Contract Duration (Months)],
        us.OldestReadingDate,
        us.LatestReadingDate,
        us.OldestReading,
        us.LatestReading,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
            ELSE NULL
        END AS AvgUsagePerDay,

        us.[Allowable Annual Hours] / 365.0 AS AllowableDailyUsage,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0) * 365
            ELSE NULL
        END AS ProjectedAnnualUsage,

        CASE
            WHEN (
                CAST(us.LatestReading - us.OldestReading AS FLOAT)
                / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
            ) > (us.[Allowable Annual Hours] / 365.0)
                THEN 'Yes'
            ELSE 'No'
        END AS OverUsageFlag,

        CASE
            WHEN DATEDIFF(MONTH, us.[Contract Start Date], GETDATE()) % 12 = 11
                 AND (
                     CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0) * 365
                 ) > us.[Allowable Annual Hours]
                THEN 'Yes'
            ELSE 'No'
        END AS OT_Billing_Alert_Flag,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN
                    CAST(us.LatestReading - us.OldestReading AS FLOAT)
                    + (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                    ) *
                    CASE
                        WHEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate) > 0
                            THEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate)
                        ELSE 0
                    END
                    + (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                    ) *
                    CASE
                        WHEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE)) > 0
                            THEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE))
                        ELSE 0
                    END
            ELSE NULL
        END AS ApproximateUsageTillDate,

        CASE
            WHEN us.[Allowable Annual Hours] IS NOT NULL
                THEN (us.[Allowable Annual Hours] / 365.0) *
                     CASE
                         WHEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE)) > 0
                             THEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE))
                         ELSE 0
                     END
            ELSE NULL
        END AS AllowableHoursTillDate,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                 AND us.[Allowable Annual Hours] IS NOT NULL
                THEN
                    (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        + (
                            CAST(us.LatestReading - us.OldestReading AS FLOAT)
                            / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                        ) *
                        CASE
                            WHEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate) > 0
                                THEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate)
                            ELSE 0
                        END
                        + (
                            CAST(us.LatestReading - us.OldestReading AS FLOAT)
                            / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                        ) *
                        CASE
                            WHEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE)) > 0
                                THEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE))
                            ELSE 0
                        END
                    )
                    - (
                        (us.[Allowable Annual Hours] / 365.0) *
                        CASE
                            WHEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE)) > 0
                                THEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE))
                            ELSE 0
                        END
                    )
            ELSE NULL
        END AS VarianceTillDate

    FROM UsageStats us
)

SELECT
    [Sell-to Customer No_],
    [Sell-to Customer Name],
    EquipmentObject,
    [Equipment Category],
    [Description],
    MaintenanceContract,
    [Contract Type],
    [MCL S date],
    [MCL F date],
    [Contract Start Date],
    [Contract End Date],
    [Allowable Annual Hours],
    [Annual Amount],
    [Monthly Amount],
    [Amount Invoiced],
    [OT Unit Price],
    [Total Allowable Hours],
    [Contract Duration (Months)],
    OldestReadingDate,
    LatestReadingDate,
    OldestReading,
    LatestReading,
    AvgUsagePerDay,
    AllowableDailyUsage,
    ProjectedAnnualUsage,
    OverUsageFlag,
    OT_Billing_Alert_Flag,
    ApproximateUsageTillDate,
    AllowableHoursTillDate,
    VarianceTillDate
FROM FinalUsage
WHERE AvgUsagePerDay < 40
AND EquipmentObject = 'HE012789'
ORDER BY EquipmentObject;

---- V3 Corrected for duplicate meter readings on the same day LTD OT MC 


WITH MaintContractLinePeriods AS (
    SELECT
        mclp.[Document No_],
        pmch.No_ AS MC,
        mclp.[Equipment Object],
        EO.[Equipment Category],
        EO.[Description],
        pmch.[Sell-to Customer No_],
        pmch.[Sell-to Customer Name],
        pmch.[Contract Type],

        MAX(mclp.[Period No_]) / 12 AS [Years of Contract],

        CASE
            WHEN DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) = 0
                THEN CAST(DATEDIFF(DAY, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) AS FLOAT)
                     / DAY(EOMONTH(MIN(mclp.[Starting Date])))
            ELSE DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date]))
        END AS [Contract Duration (Months)],

        mcl.[Starting Date] AS [MCL S date],
        mcl.[Finishing Date] AS [MCL F date],

        MIN(pmch.[Starting Date]) AS [Contract Start Date],
        MAX(pmch.[Finishing Date]) AS [Contract End Date],
        AVG(mclp.[M1 included per Year]) AS [Allowable Annual Hours],
        AVG(mclp.[Annual Amount]) AS [Annual Amount],
        AVG(mclp.[Monthly Amount]) AS [Monthly Amount],
        AVG(mclp.[Unit Price M1 Overtime Billing]) AS [OT Unit Price],
        SUM(mclp.[Amount Invoiced]) AS [Amount Invoiced],

        (
            AVG(mclp.[M1 included per Year] / 12) *
            CASE
                WHEN DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) = 0
                    THEN CAST(DATEDIFF(DAY, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) AS FLOAT)
                         / DAY(EOMONTH(MIN(mclp.[Starting Date])))
                ELSE DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date]))
            END
        ) AS [Total Allowable Hours]

    FROM [Copyofproduction].[dbo].[Production$Maint Contract Line Periods] mclp
    LEFT JOIN [Production$Equipment Object] EO
        ON mclp.[Equipment Object] = EO.[No_]
    LEFT JOIN [Production$Maintenance Contract Line] mcl
        ON mcl.[Document No_] = EO.[Maintenance Contract]
       AND mcl.[Equipment Object] = EO.No_
       AND mcl.Status IN (0, 1)
    LEFT JOIN [Production$Maintenance Contract Header] pmch
        ON mcl.[Document No_] = pmch.No_
       AND mclp.[Document No_] = pmch.No_
    WHERE pmch.[Status] IN ('1')
      AND pmch.[Contract Type] IN ('GOLD', 'PLATINUM', 'SILVER')
      AND pmch.[Document Status] NOT IN ('EXPIRED', 'CANCELLED')
      AND mcl.[Status] IN ('1')
      -- AND pmch.No_ = '003028'
      AND mclp.[M1 included per Year] <> 0
    GROUP BY
        mclp.[Document No_],
        pmch.No_,
        EO.[Description],
        mclp.[Equipment Object],
        pmch.[Sell-to Customer No_],
        pmch.[Sell-to Customer Name],
        mcl.[Starting Date],
        mcl.[Finishing Date],
        pmch.[Contract Type],
        EO.[Equipment Category]
),

/* Non-electric equipment: keep latest Meter = 1 reading per day */
NonElectricMeterReadings_Base AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.Reading AS FLOAT) AS ReadingValue,
        ROW_NUMBER() OVER (
            PARTITION BY
                mr.[Equipment Object],
                eo.[Maintenance Contract],
                CAST(mr.[DateTime] AS DATE)
            ORDER BY mr.[DateTime] DESC
        ) AS rn
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] NOT IN ('CLASS I', 'CLASS II', 'CLASS III') and mr.[Ignore in calculations] <> '1'
      AND mr.Meter = 1
),

NonElectricMeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM NonElectricMeterReadings_Base
    WHERE rn = 1
),

/* Electric equipment: keep latest Meter 2 and latest Meter 3 per day, then sum */
ElectricMeterReadings_Base AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        mr.Meter,
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.Reading AS FLOAT) AS ReadingValue,
        ROW_NUMBER() OVER (
            PARTITION BY
                mr.[Equipment Object],
                eo.[Maintenance Contract],
                mr.Meter,
                CAST(mr.[DateTime] AS DATE)
            ORDER BY mr.[DateTime] DESC
        ) AS rn
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] IN ('CLASS I', 'CLASS II', 'CLASS III') and mr.[Ignore in calculations] <> '1'
      AND mr.Meter IN (2, 3)
),

ElectricMeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        MAX(ReadingDateTime) AS ReadingDateTime,
        Reading_Date,
        CAST(SUM(ReadingValue) AS FLOAT) AS ReadingValue
    FROM ElectricMeterReadings_Base
    WHERE rn = 1
    GROUP BY
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        Reading_Date
),

/* Unified reading set */
MeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM NonElectricMeterReadings

    UNION ALL

    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM ElectricMeterReadings
),

UsageStats AS (
    SELECT
        mc.[Sell-to Customer No_],
        mc.[Sell-to Customer Name],
        mc.[Document No_] AS MaintenanceContract,
        mc.[Contract Type],
        mc.[Equipment Object] AS EquipmentObject,
        mc.[Equipment Category],
        mc.[Description],
        mc.[MCL S date],
        mc.[MCL F date],
        mc.[Contract Start Date],
        mc.[Contract End Date],
        mc.[Allowable Annual Hours],
        mc.[Annual Amount],
        mc.[Monthly Amount],
        mc.[Amount Invoiced],
        mc.[OT Unit Price],
        mc.[Total Allowable Hours],
        mc.[Contract Duration (Months)],

        oldr.OldestReading,
        oldr.OldestReadingDate,
        latestr.LatestReading,
        latestr.LatestReadingDate

    FROM MaintContractLinePeriods mc

    OUTER APPLY (
        SELECT TOP 1
            mr.ReadingValue AS OldestReading,
            mr.Reading_Date AS OldestReadingDate
        FROM MeterReadings mr
        WHERE mr.EquipmentObject = mc.[Equipment Object]
          AND mr.MaintenanceContract = mc.[Document No_]
          AND mr.Reading_Date >= mc.[MCL S date]
          AND mr.Reading_Date <= mc.[MCL F date]
        ORDER BY mr.Reading_Date ASC, mr.ReadingDateTime ASC
    ) oldr

    OUTER APPLY (
        SELECT TOP 1
            mr.ReadingValue AS LatestReading,
            mr.Reading_Date AS LatestReadingDate
        FROM MeterReadings mr
        WHERE mr.EquipmentObject = mc.[Equipment Object]
          AND mr.MaintenanceContract = mc.[Document No_]
          AND mr.Reading_Date >= mc.[MCL S date]
          AND mr.Reading_Date <= mc.[MCL F date]
        ORDER BY mr.Reading_Date DESC, mr.ReadingDateTime DESC
    ) latestr
),

FinalUsage AS (
    SELECT
        us.[Sell-to Customer No_],
        us.[Sell-to Customer Name],
        us.EquipmentObject,
        us.[Equipment Category],
        us.[Description],
        us.MaintenanceContract,
        us.[Contract Type],
        us.[MCL S date],
        us.[MCL F date],
        us.[Contract Start Date],
        us.[Contract End Date],
        us.[Allowable Annual Hours],
        us.[Annual Amount],
        us.[Monthly Amount],
        us.[Amount Invoiced],
        us.[OT Unit Price],
        us.[Total Allowable Hours],
        us.[Contract Duration (Months)],
        us.OldestReadingDate,
        us.LatestReadingDate,
        us.OldestReading,
        us.LatestReading,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
            ELSE NULL
        END AS AvgUsagePerDay,

        us.[Allowable Annual Hours] / 365.0 AS AllowableDailyUsage,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0) * 365
            ELSE NULL
        END AS ProjectedAnnualUsage,

        CASE
            WHEN (
                CAST(us.LatestReading - us.OldestReading AS FLOAT)
                / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
            ) > (us.[Allowable Annual Hours] / 365.0)
                THEN 'Yes'
            ELSE 'No'
        END AS OverUsageFlag,

        CASE
            WHEN DATEDIFF(MONTH, us.[Contract Start Date], GETDATE()) % 12 = 11
                 AND (
                     CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0) * 365
                 ) > us.[Allowable Annual Hours]
                THEN 'Yes'
            ELSE 'No'
        END AS OT_Billing_Alert_Flag,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN
                    CAST(us.LatestReading - us.OldestReading AS FLOAT)
                    + (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                    ) *
                    CASE
                        WHEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate) > 0
                            THEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate)
                        ELSE 0
                    END
                    + (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                    ) *
                    CASE
                        WHEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE)) > 0
                            THEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE))
                        ELSE 0
                    END
            ELSE NULL
        END AS ApproximateUsageTillDate,

        CASE
            WHEN us.[Allowable Annual Hours] IS NOT NULL
                THEN (us.[Allowable Annual Hours] / 365.0) *
                     CASE
                         WHEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE)) > 0
                             THEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE))
                         ELSE 0
                     END
            ELSE NULL
        END AS AllowableHoursTillDate,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                 AND us.[Allowable Annual Hours] IS NOT NULL
                THEN
                    (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        + (
                            CAST(us.LatestReading - us.OldestReading AS FLOAT)
                            / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                        ) *
                        CASE
                            WHEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate) > 0
                                THEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate)
                            ELSE 0
                        END
                        + (
                            CAST(us.LatestReading - us.OldestReading AS FLOAT)
                            / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                        ) *
                        CASE
                            WHEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE)) > 0
                                THEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE))
                            ELSE 0
                        END
                    )
                    - (
                        (us.[Allowable Annual Hours] / 365.0) *
                        CASE
                            WHEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE)) > 0
                                THEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE))
                            ELSE 0
                        END
                    )
            ELSE NULL
        END AS VarianceTillDate

    FROM UsageStats us
)

SELECT
    [Sell-to Customer No_],
    [Sell-to Customer Name],
    EquipmentObject,
    [Equipment Category],
    [Description],
    MaintenanceContract,
    [Contract Type],
    [MCL S date],
    [MCL F date],
    [Contract Start Date],
    [Contract End Date],
    [Allowable Annual Hours],
    [Annual Amount],
    [Monthly Amount],
    [Amount Invoiced],
    [OT Unit Price],
    [Total Allowable Hours],
    [Contract Duration (Months)],
    OldestReadingDate,
    LatestReadingDate,
    OldestReading,
    LatestReading,
    AvgUsagePerDay,
    AllowableDailyUsage,
    ProjectedAnnualUsage,
    OverUsageFlag,
    OT_Billing_Alert_Flag,
    ApproximateUsageTillDate,
    AllowableHoursTillDate,
    VarianceTillDate
FROM FinalUsage
WHERE AvgUsagePerDay < 40
  --AND EquipmentObject = 'HE012789'
ORDER BY EquipmentObject;

--- updated v4 optimized sql for LTD mc ot 
WITH MaintContractLinePeriods AS (
    SELECT
        mclp.[Document No_],
        pmch.No_ AS MC,
        mclp.[Equipment Object],
        EO.[Equipment Category],
        EO.[Description],
        pmch.[Sell-to Customer No_],
        pmch.[Sell-to Customer Name],
        pmch.[Contract Type],

        MAX(mclp.[Period No_]) / 12 AS [Years of Contract],

        CASE
            WHEN DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) = 0
                THEN CAST(DATEDIFF(DAY, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) AS FLOAT)
                     / DAY(EOMONTH(MIN(mclp.[Starting Date])))
            ELSE DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date]))
        END AS [Contract Duration (Months)],

        mcl.[Starting Date] AS [MCL S date],
        mcl.[Finishing Date] AS [MCL F date],

        MIN(pmch.[Starting Date]) AS [Contract Start Date],
        MAX(pmch.[Finishing Date]) AS [Contract End Date],
        AVG(mclp.[M1 included per Year]) AS [Allowable Annual Hours],
        AVG(mclp.[Annual Amount]) AS [Annual Amount],
        AVG(mclp.[Monthly Amount]) AS [Monthly Amount],
        AVG(mclp.[Unit Price M1 Overtime Billing]) AS [OT Unit Price],
        SUM(mclp.[Amount Invoiced]) AS [Amount Invoiced],

        (
            AVG(mclp.[M1 included per Year] / 12) *
            CASE
                WHEN DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) = 0
                    THEN CAST(DATEDIFF(DAY, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) AS FLOAT)
                         / DAY(EOMONTH(MIN(mclp.[Starting Date])))
                ELSE DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date]))
            END
        ) AS [Total Allowable Hours]

    FROM [Copyofproduction].[dbo].[Production$Maint Contract Line Periods] mclp
    INNER JOIN [Production$Equipment Object] EO
        ON mclp.[Equipment Object] = EO.[No_]
    INNER JOIN [Production$Maintenance Contract Line] mcl
        ON mcl.[Document No_] = EO.[Maintenance Contract]
       AND mcl.[Equipment Object] = EO.[No_]
       AND mcl.[Status] IN (0, 1)
    INNER JOIN [Production$Maintenance Contract Header] pmch
        ON mcl.[Document No_] = pmch.[No_]
       AND mclp.[Document No_] = pmch.[No_]
    WHERE pmch.[Status] IN ('1')
      AND pmch.[Contract Type] IN ('GOLD', 'PLATINUM', 'SILVER')
      AND pmch.[Document Status] NOT IN ('EXPIRED', 'CANCELLED')
      AND mcl.[Status] IN ('1')
      AND mclp.[M1 included per Year] <> 0
      -- AND pmch.[No_] = '003028'
    GROUP BY
        mclp.[Document No_],
        pmch.[No_],
        EO.[Description],
        mclp.[Equipment Object],
        pmch.[Sell-to Customer No_],
        pmch.[Sell-to Customer Name],
        mcl.[Starting Date],
        mcl.[Finishing Date],
        pmch.[Contract Type],
        EO.[Equipment Category]
),

RelevantContracts AS (
    SELECT DISTINCT
        [Document No_] AS MaintenanceContract,
        [Equipment Object] AS EquipmentObject,
        [MCL S date],
        [MCL F date]
    FROM MaintContractLinePeriods
),

/* Non-electric equipment: keep latest Meter = 1 reading per day */
NonElectricMeterReadings_Base AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.[Reading] AS FLOAT) AS ReadingValue,
        ROW_NUMBER() OVER (
            PARTITION BY
                mr.[Equipment Object],
                eo.[Maintenance Contract],
                CAST(mr.[DateTime] AS DATE)
            ORDER BY mr.[DateTime] DESC
        ) AS rn
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    INNER JOIN RelevantContracts rc
        ON eo.[Maintenance Contract] = rc.MaintenanceContract
       AND mr.[Equipment Object] = rc.EquipmentObject
       AND CAST(mr.[DateTime] AS DATE) >= rc.[MCL S date]
       AND CAST(mr.[DateTime] AS DATE) <= rc.[MCL F date]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] NOT IN ('CLASS I', 'CLASS II', 'CLASS III')
      AND mr.[Ignore in calculations] <> '1'
      AND mr.[Meter] = 1
),

NonElectricMeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM NonElectricMeterReadings_Base
    WHERE rn = 1
),

/* Electric equipment: keep latest Meter 2 and latest Meter 3 per day, then sum */
ElectricMeterReadings_Base AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        mr.[Meter],
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.[Reading] AS FLOAT) AS ReadingValue,
        ROW_NUMBER() OVER (
            PARTITION BY
                mr.[Equipment Object],
                eo.[Maintenance Contract],
                mr.[Meter],
                CAST(mr.[DateTime] AS DATE)
            ORDER BY mr.[DateTime] DESC
        ) AS rn
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    INNER JOIN RelevantContracts rc
        ON eo.[Maintenance Contract] = rc.MaintenanceContract
       AND mr.[Equipment Object] = rc.EquipmentObject
       AND CAST(mr.[DateTime] AS DATE) >= rc.[MCL S date]
       AND CAST(mr.[DateTime] AS DATE) <= rc.[MCL F date]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] IN ('CLASS I', 'CLASS II', 'CLASS III')
      AND mr.[Ignore in calculations] <> '1'
      AND mr.[Meter] IN (2, 3)
),

ElectricMeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        MAX(ReadingDateTime) AS ReadingDateTime,
        Reading_Date,
        CAST(SUM(ReadingValue) AS FLOAT) AS ReadingValue
    FROM ElectricMeterReadings_Base
    WHERE rn = 1
    GROUP BY
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        Reading_Date
),

/* Unified reading set */
MeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM NonElectricMeterReadings

    UNION ALL

    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM ElectricMeterReadings
),

UsageStats AS (
    SELECT
        mc.[Sell-to Customer No_],
        mc.[Sell-to Customer Name],
        mc.[Document No_] AS MaintenanceContract,
        mc.[Contract Type],
        mc.[Equipment Object] AS EquipmentObject,
        mc.[Equipment Category],
        mc.[Description],
        mc.[MCL S date],
        mc.[MCL F date],
        mc.[Contract Start Date],
        mc.[Contract End Date],
        mc.[Allowable Annual Hours],
        mc.[Annual Amount],
        mc.[Monthly Amount],
        mc.[Amount Invoiced],
        mc.[OT Unit Price],
        mc.[Total Allowable Hours],
        mc.[Contract Duration (Months)],

        oldr.OldestReading,
        oldr.OldestReadingDate,
        latestr.LatestReading,
        latestr.LatestReadingDate

    FROM MaintContractLinePeriods mc

    OUTER APPLY (
        SELECT TOP 1
            mr.ReadingValue AS OldestReading,
            mr.Reading_Date AS OldestReadingDate
        FROM MeterReadings mr
        WHERE mr.EquipmentObject = mc.[Equipment Object]
          AND mr.MaintenanceContract = mc.[Document No_]
          AND mr.Reading_Date >= mc.[MCL S date]
          AND mr.Reading_Date <= mc.[MCL F date]
        ORDER BY mr.Reading_Date ASC, mr.ReadingDateTime ASC
    ) oldr

    OUTER APPLY (
        SELECT TOP 1
            mr.ReadingValue AS LatestReading,
            mr.Reading_Date AS LatestReadingDate
        FROM MeterReadings mr
        WHERE mr.EquipmentObject = mc.[Equipment Object]
          AND mr.MaintenanceContract = mc.[Document No_]
          AND mr.Reading_Date >= mc.[MCL S date]
          AND mr.Reading_Date <= mc.[MCL F date]
        ORDER BY mr.Reading_Date DESC, mr.ReadingDateTime DESC
    ) latestr
),

FinalUsage AS (
    SELECT
        us.[Sell-to Customer No_],
        us.[Sell-to Customer Name],
        us.EquipmentObject,
        us.[Equipment Category],
        us.[Description],
        us.MaintenanceContract,
        us.[Contract Type],
        us.[MCL S date],
        us.[MCL F date],
        us.[Contract Start Date],
        us.[Contract End Date],
        us.[Allowable Annual Hours],
        us.[Annual Amount],
        us.[Monthly Amount],
        us.[Amount Invoiced],
        us.[OT Unit Price],
        us.[Total Allowable Hours],
        us.[Contract Duration (Months)],
        us.OldestReadingDate,
        us.LatestReadingDate,
        us.OldestReading,
        us.LatestReading,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
            ELSE NULL
        END AS AvgUsagePerDay,

        us.[Allowable Annual Hours] / 365.0 AS AllowableDailyUsage,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0) * 365
            ELSE NULL
        END AS ProjectedAnnualUsage,

        CASE
            WHEN (
                CAST(us.LatestReading - us.OldestReading AS FLOAT)
                / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
            ) > (us.[Allowable Annual Hours] / 365.0)
                THEN 'Yes'
            ELSE 'No'
        END AS OverUsageFlag,

        CASE
            WHEN DATEDIFF(MONTH, us.[Contract Start Date], GETDATE()) % 12 = 11
                 AND (
                     CAST(us.LatestReading - us.OldestReading AS FLOAT)
                     / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0) * 365
                 ) > us.[Allowable Annual Hours]
                THEN 'Yes'
            ELSE 'No'
        END AS OT_Billing_Alert_Flag,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                THEN
                    CAST(us.LatestReading - us.OldestReading AS FLOAT)
                    + (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                    ) *
                    CASE
                        WHEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate) > 0
                            THEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate)
                        ELSE 0
                    END
                    + (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                    ) *
                    CASE
                        WHEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE)) > 0
                            THEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE))
                        ELSE 0
                    END
            ELSE NULL
        END AS ApproximateUsageTillDate,

        CASE
            WHEN us.[Allowable Annual Hours] IS NOT NULL
                THEN (us.[Allowable Annual Hours] / 365.0) *
                     CASE
                         WHEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE)) > 0
                             THEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE))
                         ELSE 0
                     END
            ELSE NULL
        END AS AllowableHoursTillDate,

        CASE
            WHEN DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate) > 0
                 AND us.[Allowable Annual Hours] IS NOT NULL
                THEN
                    (
                        CAST(us.LatestReading - us.OldestReading AS FLOAT)
                        + (
                            CAST(us.LatestReading - us.OldestReading AS FLOAT)
                            / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                        ) *
                        CASE
                            WHEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate) > 0
                                THEN DATEDIFF(DAY, us.[MCL S date], us.OldestReadingDate)
                            ELSE 0
                        END
                        + (
                            CAST(us.LatestReading - us.OldestReading AS FLOAT)
                            / NULLIF(DATEDIFF(DAY, us.OldestReadingDate, us.LatestReadingDate), 0)
                        ) *
                        CASE
                            WHEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE)) > 0
                                THEN DATEDIFF(DAY, us.LatestReadingDate, CAST(GETDATE() AS DATE))
                            ELSE 0
                        END
                    )
                    - (
                        (us.[Allowable Annual Hours] / 365.0) *
                        CASE
                            WHEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE)) > 0
                                THEN DATEDIFF(DAY, us.[MCL S date], CAST(GETDATE() AS DATE))
                            ELSE 0
                        END
                    )
            ELSE NULL
        END AS VarianceTillDate

    FROM UsageStats us
)

SELECT
    [Sell-to Customer No_],
    [Sell-to Customer Name],
    EquipmentObject,
    [Equipment Category],
    [Description],
    MaintenanceContract,
    [Contract Type],
    [MCL S date],
    [MCL F date],
    [Contract Start Date],
    [Contract End Date],
    [Allowable Annual Hours],
    [Annual Amount],
    [Monthly Amount],
    [Amount Invoiced],
    [OT Unit Price],
    [Total Allowable Hours],
    [Contract Duration (Months)],
    OldestReadingDate,
    LatestReadingDate,
    OldestReading,
    LatestReading,
    AvgUsagePerDay,
    AllowableDailyUsage,
    ProjectedAnnualUsage,
    OverUsageFlag,
    OT_Billing_Alert_Flag,
    ApproximateUsageTillDate,
    AllowableHoursTillDate,
    VarianceTillDate
FROM FinalUsage
WHERE AvgUsagePerDay < 40
-- AND EquipmentObject = 'HE012789'
ORDER BY EquipmentObject;


---- V2 MC OT Tables



--1) WITH MaintContractLinePeriods AS (
    SELECT
        mclp.[Document No_],
        pmch.No_ AS MC,
        mclp.[Equipment Object],
        EO.[Equipment Category],
        EO.[Description],
        pmch.[Sell-to Customer No_],
        pmch.[Sell-to Customer Name],
        pmch.[Contract Type],

        MAX(mclp.[Period No_]) / 12 AS [Years of Contract],

        CASE
            WHEN DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) = 0
                THEN CAST(DATEDIFF(DAY, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) AS FLOAT)
                     / DAY(EOMONTH(MIN(mclp.[Starting Date])))
            ELSE DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date]))
        END AS [Contract Duration (Months)],

        mcl.[Starting Date] AS [MCL S date],
        mcl.[Finishing Date] AS [MCL F date],

        MIN(pmch.[Starting Date]) AS [Contract Start Date],
        MAX(pmch.[Finishing Date]) AS [Contract End Date],
        AVG(mclp.[M1 included per Year]) AS [Allowable Annual Hours],
        AVG(mclp.[Annual Amount]) AS [Annual Amount],
        AVG(mclp.[Monthly Amount]) AS [Monthly Amount],
        AVG(mclp.[Unit Price M1 Overtime Billing]) AS [OT Unit Price],
        SUM(mclp.[Amount Invoiced]) AS [Amount Invoiced],

        (
            AVG(mclp.[M1 included per Year] / 12) *
            CASE
                WHEN DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) = 0
                    THEN CAST(DATEDIFF(DAY, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date])) AS FLOAT)
                         / DAY(EOMONTH(MIN(mclp.[Starting Date])))
                ELSE DATEDIFF(MONTH, MIN(mclp.[Starting Date]), MAX(mclp.[Finishing Date]))
            END
        ) AS [Total Allowable Hours]

    FROM [Copyofproduction].[dbo].[Production$Maint Contract Line Periods] mclp
    LEFT JOIN [Production$Equipment Object] EO
        ON mclp.[Equipment Object] = EO.[No_]
    LEFT JOIN [Production$Maintenance Contract Line] mcl
        ON mcl.[Document No_] = EO.[Maintenance Contract]
       AND mcl.[Equipment Object] = EO.No_
       AND mcl.Status IN (0, 1)
    LEFT JOIN [Production$Maintenance Contract Header] pmch
        ON mcl.[Document No_] = pmch.No_
       AND mclp.[Document No_] = pmch.No_
    WHERE pmch.[Status] IN ('1')
      AND pmch.[Contract Type] IN ('GOLD', 'PLATINUM', 'SILVER')
      AND pmch.[Document Status] NOT IN ('EXPIRED', 'CANCELLED')
      AND mcl.[Status] IN ('1')
      -- AND pmch.No_ = '003028'
      AND mclp.[M1 included per Year] <> 0
    GROUP BY
        mclp.[Document No_],
        pmch.No_,
        EO.[Description],
        mclp.[Equipment Object],
        pmch.[Sell-to Customer No_],
        pmch.[Sell-to Customer Name],
        mcl.[Starting Date],
        mcl.[Finishing Date],
        pmch.[Contract Type],
        EO.[Equipment Category]



--2) Meter readings 

with NonElectricMeterReadings AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.Reading AS FLOAT) AS ReadingValue
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] NOT IN ('CLASS I', 'CLASS II', 'CLASS III')
      AND mr.Meter = 1 
      --and mr.[DateTime] >= '2024-01-01' 
      and eo.[Maintenance Contract] <> '' AND mr.[Equipment Object] = 'HE012789'
),

/* Electric equipment: sum Meter 2 + Meter 3 for the same equipment and same day */
ElectricMeterReadings AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
       -- Max(mr.[DateTime]) AS ReadingDateTime,
        max(CAST(mr.[DateTime] AS DATE)) AS Reading_Date,
        CAST(sum(mr.Reading) AS FLOAT) AS ReadingValue
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] IN ('CLASS I', 'CLASS II', 'CLASS III')
      AND mr.Meter IN (2, 3) 
      --and mr.[DateTime] >= '2024-01-01'
       and eo.[Maintenance Contract] <> '' AND mr.[Equipment Object] = 'HE012789'
    GROUP BY
        mr.[Equipment Object],
        eo.[Maintenance Contract],
        eo.[Equipment Category],
        CAST(mr.[DateTime] AS DATE)
)

/* Unified reading set */

    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM NonElectricMeterReadings
 where 
 --Reading_Date >= '2024-01-01' and 
 MaintenanceContract <> '' AND EquipmentObject = 'HE012789'
    UNION ALL

    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM ElectricMeterReadings
    where 
    --Reading_Date >= '2024-01-01' and 
    MaintenanceContract <> '' AND EquipmentObject = 'HE012789'





    ---- corrected meter reading electric and non electric for duplicate readings on the same date /BEFORE ADDING DEAD MAN LOGIC HRS

    WITH NonElectricMeterReadings_Base AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.Reading AS FLOAT) AS ReadingValue,
        ROW_NUMBER() OVER (
            PARTITION BY
                mr.[Equipment Object],
                eo.[Maintenance Contract],
                CAST(mr.[DateTime] AS DATE)
            ORDER BY mr.[DateTime] DESC
        ) AS rn
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] NOT IN ('CLASS I', 'CLASS II', 'CLASS III') and mr.[Ignore in calculations] <> '1'
      AND mr.Meter = 1
       AND mr.[DateTime] >= '2024-01-01'
      AND eo.[Maintenance Contract] <> ''
      --AND mr.[Equipment Object] = 'HE012789'
),

NonElectricMeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM NonElectricMeterReadings_Base
    WHERE rn = 1
),

ElectricMeterReadings_Base AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category],
        mr.Meter,
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.Reading AS FLOAT) AS ReadingValue,
        ROW_NUMBER() OVER (
            PARTITION BY
                mr.[Equipment Object],
                eo.[Maintenance Contract],
                mr.Meter,
                CAST(mr.[DateTime] AS DATE)
            ORDER BY mr.[DateTime] DESC
        ) AS rn
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
      AND eo.[Equipment Category] IN ('CLASS I', 'CLASS II', 'CLASS III') and mr.[Ignore in calculations] <> '1'
      AND mr.Meter IN (1, 2, 3, 4)
      AND mr.[DateTime] >= '2024-01-01'
      AND eo.[Maintenance Contract] <> ''
      --AND mr.[Equipment Object] = 'HE012789'
),

ElectricMeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        MAX(ReadingDateTime) AS ReadingDateTime,
        Reading_Date,
        CAST(SUM(ReadingValue) AS FLOAT) AS ReadingValue
    FROM ElectricMeterReadings_Base
    WHERE rn = 1
    GROUP BY
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category],
        Reading_Date
)

SELECT
    EquipmentObject,
    MaintenanceContract,
    [Equipment Category],
    ReadingDateTime,
    Reading_Date,
    ReadingValue
FROM NonElectricMeterReadings
WHERE MaintenanceContract <> '' 
--and EquipmentObject = 'E122618'
  --AND EquipmentObject = 'HE012789'

UNION ALL

SELECT
    EquipmentObject,
    MaintenanceContract,
    [Equipment Category],
    ReadingDateTime,
    Reading_Date,
    ReadingValue
FROM ElectricMeterReadings
WHERE MaintenanceContract <> '' 
--and EquipmentObject = 'E122618'
 -- AND EquipmentObject = 'HE012789'

ORDER BY Reading_Date DESC, ReadingDateTime DESC;





select top 100 * from [Production$Maint Contract Line Periods]
where [Equipment Object] = 'E117078'



--test mr 
select top 100 * FROM [Production$Meter Reading]
where [Equipment Object] = 'E122618'


select DISTINCT [Equipment Group]  FROM [Production$Equipment Object]
where [Equipment Category] = 'CLASS II' 
--and [Equipment Group] = 'E3W'



--- aFTER adding Deadman Hours updated electric unit logic 

WITH NonElectricMeterReadings_Base AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category], eo.[Equipment Model],eo.[Serial No_],
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.Reading AS INT) AS ReadingValue,
        ROW_NUMBER() OVER (
            PARTITION BY
                mr.[Equipment Object],
                eo.[Maintenance Contract],
                CAST(mr.[DateTime] AS DATE)
            ORDER BY mr.[DateTime] DESC
        ) AS rn
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
        AND eo.[Equipment Category] NOT IN ('CLASS I', 'CLASS II', 'CLASS III')
        AND mr.[Ignore in calculations] <> '1'
        AND mr.Meter = 1
        AND mr.[DateTime] >= '2024-01-01'
        AND eo.[Maintenance Contract] <> ''
),

NonElectricMeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category], [Equipment Model],[Serial No_],
        ReadingDateTime,
        Reading_Date,
        ReadingValue
    FROM NonElectricMeterReadings_Base
    WHERE rn = 1
),

ElectricMeterReadings_Base AS (
    SELECT
        mr.[Equipment Object] AS EquipmentObject,
        eo.[Maintenance Contract] AS MaintenanceContract,
        eo.[Equipment Category], eo.[Equipment Model],eo.[Serial No_],
        eo.[Equipment Group],
        mr.Meter,
        mr.[DateTime] AS ReadingDateTime,
        CAST(mr.[DateTime] AS DATE) AS Reading_Date,
        CAST(mr.Reading AS FLOAT) AS ReadingValue,
        ROW_NUMBER() OVER (
            PARTITION BY
                mr.[Equipment Object],
                eo.[Maintenance Contract],
                mr.Meter,
                CAST(mr.[DateTime] AS DATE)
            ORDER BY mr.[DateTime] DESC
        ) AS rn
    FROM [Production$Meter Reading] mr
    INNER JOIN [Production$Equipment Object] eo
        ON mr.[Equipment Object] = eo.[No_]
    WHERE eo.[Blocked] = 0
        AND eo.[Equipment Category] IN ('CLASS I', 'CLASS II', 'CLASS III')
        AND mr.[Ignore in calculations] <> '1'
        AND mr.Meter IN (1, 2, 3, 4)
        AND mr.[DateTime] >= '2024-01-01'
        AND eo.[Maintenance Contract] <> ''
),

ElectricMeterReadings_Pivot AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category], [Equipment Model],[Serial No_],
        [Equipment Group],
        Reading_Date,
        MAX(ReadingDateTime) AS ReadingDateTime,
        MAX(CASE WHEN Meter = 1 THEN ReadingValue END) AS KeyHours,
        MAX(CASE WHEN Meter = 2 THEN ReadingValue END) AS PumpHours,
        MAX(CASE WHEN Meter = 3 THEN ReadingValue END) AS DriveHours,
        MAX(CASE WHEN Meter = 4 THEN ReadingValue END) AS DeadManHours
    FROM ElectricMeterReadings_Base
    WHERE rn = 1
    GROUP BY
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category], [Equipment Model],[Serial No_],
        [Equipment Group],
        Reading_Date
),

ElectricMeterReadings AS (
    SELECT
        EquipmentObject,
        MaintenanceContract,
        [Equipment Category], [Equipment Model],[Serial No_],
        ReadingDateTime,
        Reading_Date,
        cast(
            CASE
                WHEN [Equipment Category] = 'CLASS I'
                    AND [Equipment Group] <> 'ESTAND'
                    THEN
                        CASE
                            WHEN ISNULL(PumpHours, 0) + ISNULL(DriveHours, 0) > ISNULL(KeyHours, 0)
                                THEN ISNULL(KeyHours, 0)
                            ELSE ISNULL(PumpHours, 0) + ISNULL(DriveHours, 0)
                        END

                WHEN [Equipment Category] = 'CLASS I'
                    AND [Equipment Group] = 'ESTAND'
                    THEN ISNULL(DeadManHours, 0)

                WHEN [Equipment Category] = 'CLASS II'
                    AND [Equipment Group] IN ('ESTAND', 'ORDER PICKER', 'REACH TRUCK')
                    THEN ISNULL(DeadManHours, 0)

                WHEN [Equipment Category] = 'CLASS II'
                    THEN ISNULL(KeyHours, 0)

                WHEN [Equipment Category] = 'CLASS III'
                    THEN ISNULL(KeyHours, 0)
            END as INT )
         AS ReadingValue
    FROM ElectricMeterReadings_Pivot
)

SELECT
    EquipmentObject,
    MaintenanceContract,
    [Equipment Category], [Equipment Model],[Serial No_],
    ReadingDateTime,
    Reading_Date,
    ReadingValue
FROM NonElectricMeterReadings
WHERE MaintenanceContract <> '' 
--and EquipmentObject = 'E122618'

UNION ALL

SELECT
    EquipmentObject,
    MaintenanceContract,
    [Equipment Category], [Equipment Model],[Serial No_],
    ReadingDateTime,
    Reading_Date,
    ReadingValue
FROM ElectricMeterReadings
WHERE MaintenanceContract <> '' 
--and EquipmentObject = 'E122618'

ORDER BY
    Reading_Date DESC,
    ReadingDateTime DESC;