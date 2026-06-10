----final MC GP SPLIT NEW MAR 1 

SELECT
    -- month bucket (first day of month)
    DATEFROMPARTS(YEAR(gl.[Posting Date]), MONTH(gl.[Posting Date]), 1) AS [Posting Date],
    --,gl.[G_L Account No_],
    gl.[Global Dimension 1 Code] as [CSC],

    UPPER(
        CASE
            WHEN mch.[Contract Type] = 'GOLD' OR woh.[Service Type] LIKE '%GOLD%' THEN 'GOLD'
            WHEN mch.[Contract Type] = 'PLATINUM' OR woh.[Service Type] LIKE '%PLAT%' THEN 'PLATINUM'
            WHEN mch.[Contract Type] = 'SILVER' OR woh.[Service Type] LIKE '%SILVER%' THEN 'SILVER'
            ELSE 'OTHER'
        END
    ) AS [Contract Type],

    -- revenue: 43030
    -SUM(CASE WHEN gl.[G_L Account No_] = '43030' THEN gl.[Amount] ELSE 0 END) AS [Revenue],

    -- cost: 53020 + 53030
    SUM(CASE WHEN gl.[G_L Account No_] IN ('53020','53030') THEN gl.[Amount] ELSE 0 END) AS [Cost],

    -- gp = revenue - cost
    -SUM(CASE WHEN gl.[G_L Account No_] = '43030' THEN gl.[Amount] ELSE 0 END)
    - SUM(CASE WHEN gl.[G_L Account No_] IN ('53020','53030') THEN gl.[Amount] ELSE 0 END) AS [GP],

    -- gp% = gp / revenue
    (
       - SUM(CASE WHEN gl.[G_L Account No_] = '43030' THEN gl.[Amount] ELSE 0 END)
        - SUM(CASE WHEN gl.[G_L Account No_] IN ('53020','53030') THEN gl.[Amount] ELSE 0 END)
    )
    / NULLIF(-SUM(CASE WHEN gl.[G_L Account No_] = '43030' THEN gl.[Amount] ELSE 0 END), 0) AS [GP_PCT]

FROM [Copyofproduction].[dbo].[Production$G_L Entry] gl
LEFT JOIN [Production$Maintenance Contract Header] mch
    ON mch.[No_] = gl.[ELC Document No_]
LEFT JOIN [Production$Work Order Header] woh
    ON woh.[No_] = gl.[Work Order No_]

WHERE
    gl.[Posting Date] >= '2024-01-01'AND 
    --AND gl.[Posting Date] <  '2026-02-01'   -- use an open-ended month range (recommended)
    --AND 
    gl.[G_L Account No_] IN ('43030','53030','53020')
    --AND gl.[Global Dimension 1 Code] = '3'

GROUP BY
    DATEFROMPARTS(YEAR(gl.[Posting Date]), MONTH(gl.[Posting Date]), 1),gl.[Global Dimension 1 Code] ,
    --gl.[G_L Account No_],
    UPPER(
        CASE
            WHEN mch.[Contract Type] = 'GOLD' OR woh.[Service Type] LIKE '%GOLD%' THEN 'GOLD'
            WHEN mch.[Contract Type] = 'PLATINUM' OR woh.[Service Type] LIKE '%PLAT%' THEN 'PLATINUM'
            WHEN mch.[Contract Type] = 'SILVER' OR woh.[Service Type] LIKE '%SILVER%' THEN 'SILVER'
            ELSE 'OTHER'
        END
    )
ORDER BY
    [Posting Date],[Contract Type];
