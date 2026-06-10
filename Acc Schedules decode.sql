--Account schedule

SELECT 
      [Schedule Name]
      ,[Row No_]
      ,[Description]
      ,[Totaling]
      --,[Bold]
      --,[Italic]
      --,[Underline]
  FROM [Copyofproduction ].[dbo].[Production$Acc_ Schedule Line]
  where [Schedule Name] in ('CONSOLSERV')


  ---GL Entry Actual
  Select sum([Amount]) from [Production$G_L Entry]
  where [G_L Account No_] = '53010' and [Posting Date]
   --= '07/31/2025' 
   between '07/01/2025' and '07/31/2025' 
   and [Global Dimension 1 Code] = '1' -- CSC 1 LOUISVILLE
   and [Global Dimension 2 Code] = '5' --service PC

  ---GL 
  Select  * from [Production$G_L Entry]
  where [G_L Account No_] = '44005' and [Posting Date] between '07/01/2025' and '07/31/2025' and [Global Dimension 2 Code] = '4'

  
  
  
  ------ TEST THIS TOTAL EXPENSE BY SELECTEING EACH CODE PART 

SELECT 
  --[Posting Date], [Global Dimension 1 Code],[G_L Account No_],
   -SUM([Amount]) AS GLActual
FROM [Production$G_L Entry]
WHERE [Posting Date] BETWEEN '2025-07-01' AND '2025-07-31'
  AND [Global Dimension 1 Code] = '5'
  AND [Global Dimension 2 Code] = '4'
  AND (
        ([G_L Account No_] BETWEEN 61100 AND 61140) OR 
([G_L Account No_] IN (61145,61146,61158,61161,61411,61415)) OR
([G_L Account No_] BETWEEN 61150 AND 61160) OR
([G_L Account No_] BETWEEN 61200 AND 61250) OR
([G_L Account No_] BETWEEN 61300 AND 61405) OR
([G_L Account No_] BETWEEN 61420 AND 61450) OR

/* Occupancy Expenses (OE / TOE) */
([G_L Account No_] BETWEEN 62005 AND 62010) OR
([G_L Account No_] = 62055) OR
([G_L Account No_] BETWEEN 62015 AND 62050) OR
([G_L Account No_] = 62060) OR

/* Vehicle Expenses (VE / TVE) */
([G_L Account No_] BETWEEN 63005 AND 63011) OR 
([G_L Account No_] BETWEEN 63031 AND 63035) OR 
([G_L Account No_] BETWEEN 63025 AND 63030) OR
([G_L Account No_] BETWEEN 63015 AND 63023) OR

/* G&A (GA / TGA) */
([G_L Account No_] = 65030) OR
([G_L Account No_] BETWEEN 65005 AND 65025) OR
([G_L Account No_] BETWEEN 65035 AND 65070) OR

/* Misc Expenses (ME / TME) */
([G_L Account No_] IN (66020,66110,66005,66030,66105,66115,64999)) OR
([G_L Account No_] BETWEEN 66032 AND 66035) OR
([G_L Account No_] = 66003) OR
([G_L Account No_] BETWEEN 66010 AND 66016) OR
([G_L Account No_] BETWEEN 66021 AND 66026) OR
([G_L Account No_] BETWEEN 66036 AND 66100) OR
([G_L Account No_] BETWEEN 66200 AND 66900) OR

/* Other Expenses (Income) — “36” in schedule */
([G_L Account No_] BETWEEN 70005 AND 70030) OR
([G_L Account No_] BETWEEN 71005 AND 71035)

  )

--GROUP BY [Posting Date],[Global Dimension 1 Code],[G_L Account No_];

--kpi parts 

WITH GLData AS (
    SELECT 
    [Global Dimension 1 Code] as CSC,
        [G_L Account No_] AS GLAccount,
        [Posting Date],
        -SUM([Amount]) AS GLActual
    FROM [Production$G_L Entry]
    WHERE [Posting Date] BETWEEN '2025-07-01' AND '2025-07-31'
     AND [Global Dimension 1 Code] = '5'
      AND [Global Dimension 2 Code] = '4'
    GROUP BY [G_L Account No_],[Global Dimension 1 Code],[Posting Date]
)

SELECT 
CSC,[Posting Date],
    SUM(CASE 
            WHEN GLAccount BETWEEN '44005' AND '44006' OR
        GLAccount IN ('40020', '44007') or
        GLAccount between '44010' and '44011' 
        OR
    GLAccount = '44012' 
        OR
        GLAccount BETWEEN '44013' AND '44015' OR
        GLAccount BETWEEN '46005' AND '46006' OR
        GLAccount BETWEEN '46010' AND '46015' OR
        GLAccount BETWEEN '46035' AND '46036' OR
        GLAccount BETWEEN '46040' AND '46041' OR
        GLAccount = '40090' 
            THEN GLActual ELSE 0 END) AS Total_Sales,

    SUM(CASE 
            WHEN GLAccount BETWEEN '44005' AND '44006' OR
GLAccount BETWEEN '54005' AND '54006' OR
GLAccount IN ('40020', '50020', '44007', '54007') OR
GLAccount BETWEEN '44010' AND '44011' OR
GLAccount BETWEEN '54010' AND '54011' OR
GLAccount = '44012' OR
GLAccount = '54012' OR
GLAccount BETWEEN '44013' AND '44015' OR
GLAccount BETWEEN '54013' AND '54015' OR
GLAccount BETWEEN '46005' AND '46006' OR
GLAccount BETWEEN '56005' AND '56007' OR
GLAccount = '56020' OR
GLAccount BETWEEN '46010' AND '46015' OR
GLAccount BETWEEN '56008' AND '56013' OR
GLAccount = '56015' OR
GLAccount BETWEEN '46035' AND '46036' OR
GLAccount = '56035' OR
GLAccount BETWEEN '46040' AND '46041' OR
GLAccount IN (
    '46040', '46041', '56040', '53110',
    '56070', '56095', '40090',
    '56025', '56080',  -- Inventory adjustments (possible $10 diff)
    '56085', '56016', '56086', '56090', '53012'
)

            THEN GLActual ELSE 0 END) AS Total_GP,

    CASE 
        WHEN SUM(CASE 
                    WHEN GLAccount BETWEEN '44005' AND '44006' OR
                         GLAccount IN ('40020', '44007') OR
                         GLAccount BETWEEN '44010' AND '44011' OR
                         GLAccount = '44012' OR
                         GLAccount BETWEEN '44013' AND '44015' OR
                         GLAccount BETWEEN '46005' AND '46006' OR
                         GLAccount BETWEEN '46010' AND '46015' OR
                         GLAccount BETWEEN '46035' AND '46036' OR
                         GLAccount BETWEEN '46040' AND '46041' OR
                         GLAccount = '40090'
                    THEN GLActual ELSE 0 END) <> 0
        THEN 
            SUM(CASE 
                    WHEN GLAccount BETWEEN '44005' AND '44006' OR
GLAccount BETWEEN '54005' AND '54006' OR
GLAccount IN ('40020', '50020', '44007', '54007') OR
GLAccount BETWEEN '44010' AND '44011' OR
GLAccount BETWEEN '54010' AND '54011' OR
GLAccount = '44012' OR
GLAccount = '54012' OR
GLAccount BETWEEN '44013' AND '44015' OR
GLAccount BETWEEN '54013' AND '54015' OR
GLAccount BETWEEN '46005' AND '46006' OR
GLAccount BETWEEN '56005' AND '56007' OR
GLAccount = '56020' OR
GLAccount BETWEEN '46010' AND '46015' OR
GLAccount BETWEEN '56008' AND '56013' OR
GLAccount = '56015' OR
GLAccount BETWEEN '46035' AND '46036' OR
GLAccount = '56035' OR
GLAccount BETWEEN '46040' AND '46041' OR
GLAccount IN (
    '46040', '46041', '56040', '53110',
    '56070', '56095', '40090',
    '56025', '56080',  -- Inventory adjustments (possible $10 diff)
    '56085', '56016', '56086', '56090', '53012'
)

                    THEN GLActual ELSE 0 END)
            /
            SUM(CASE 
                    WHEN GLAccount BETWEEN '44005' AND '44006' OR
                         GLAccount IN ('40020', '44007') OR
                         GLAccount BETWEEN '44010' AND '44011' OR
                         GLAccount = '44012' OR
                         GLAccount BETWEEN '44013' AND '44015' OR
                         GLAccount BETWEEN '46005' AND '46006' OR
                         GLAccount BETWEEN '46010' AND '46015' OR
                         GLAccount BETWEEN '46035' AND '46036' OR
                         GLAccount BETWEEN '46040' AND '46041' OR
                         GLAccount = '40090'
                    THEN GLActual ELSE 0 END)
        ELSE NULL END AS GP_Percent

FROM GLData
where CSC = '5'
group by CSC,[Posting Date];



------xxxxxxxxxxxxxxxxxxxx kpi parts all in one xxxxxxxxxxxx---------------- total expensce and inet operating income has issues



;WITH GLData AS
(
    SELECT
        [Global Dimension 1 Code] AS CSC,
        CAST([G_L Account No_] AS int) AS GLAccount,
        CONVERT(date, DATEFROMPARTS(YEAR([Posting Date]), MONTH([Posting Date]), 1)) AS PostingMonth,
        -SUM([Amount]) AS GLActual
    FROM [Production$G_L Entry]
    WHERE [Posting Date] >= '2025-01-01'
      AND [Global Dimension 2 Code] = '4'         -- ProfitCenter (keep your filter)
    GROUP BY
        [Global Dimension 1 Code],
        CAST([G_L Account No_] AS int),
        DATEFROMPARTS(YEAR([Posting Date]), MONTH([Posting Date]), 1)
)
SELECT
    g.CSC,
    g.PostingMonth,

    /* ------------------ SALES ------------------ */
    Total_Sales =
        SUM(CASE WHEN
                (GLAccount BETWEEN 44005 AND 44006) OR
                (GLAccount IN (40020, 44007)) OR
                (GLAccount BETWEEN 44010 AND 44011) OR
                (GLAccount = 44012) OR
                (GLAccount BETWEEN 44013 AND 44015) OR
                (GLAccount BETWEEN 46005 AND 46006) OR
                (GLAccount BETWEEN 46010 AND 46015) OR
                (GLAccount BETWEEN 46035 AND 46036) OR
                (GLAccount BETWEEN 46040 AND 46041) OR
                (GLAccount = 40090)
            THEN GLActual ELSE 0 END),

    /* ------------------ GP (your original list) ------------------ */
    Total_GP =
        SUM(CASE WHEN
                (GLAccount BETWEEN 44005 AND 44006) OR
                (GLAccount BETWEEN 54005 AND 54006) OR
                (GLAccount IN (40020,50020,44007,54007)) OR
                (GLAccount BETWEEN 44010 AND 44011) OR
                (GLAccount BETWEEN 54010 AND 54011) OR
                (GLAccount = 44012) OR
                (GLAccount = 54012) OR
                (GLAccount BETWEEN 44013 AND 44015) OR
                (GLAccount BETWEEN 54013 AND 54015) OR
                (GLAccount BETWEEN 46005 AND 46006) OR
                (GLAccount BETWEEN 56005 AND 56007) OR
                (GLAccount = 56020) OR
                (GLAccount BETWEEN 46010 AND 46015) OR
                (GLAccount BETWEEN 56008 AND 56013) OR
                (GLAccount = 56015) OR
                (GLAccount BETWEEN 46035 AND 46036) OR
                (GLAccount = 56035) OR
                (GLAccount BETWEEN 46040 AND 46041) OR
                (GLAccount IN (46040,46041,56040,53110,56070,56095,40090,
                               56025,56080,56085,56016,56086,56090,53012))
            THEN GLActual ELSE 0 END),

    /* ------------------ EXPENSES (TE) ------------------
       EE + OE + VE + G&A + Misc + Other Income (7000/7100)
       Based on the totaling column in your schedule screenshot         */
    Total_Expenses =
        SUM(CASE WHEN
                /* Employee Expenses (EE / TEE) */
                (GLAccount BETWEEN 61100 AND 61140) OR
                (GLAccount IN (61145,61146,61158,61161,61411,61415)) OR
                (GLAccount BETWEEN 61150 AND 61160) OR
                (GLAccount BETWEEN 61200 AND 61250) OR
                (GLAccount BETWEEN 61300 AND 61405) OR
                (GLAccount BETWEEN 61420 AND 61450) OR

                /* Occupancy Expenses (OE / TOE) */
                (GLAccount BETWEEN 62005 AND 62010) OR
                (GLAccount = 62055) OR
                (GLAccount BETWEEN 62015 AND 62050) OR
                (GLAccount = 62060) OR

                /* Vehicle Expenses (VE / TVE) */
                (GLAccount BETWEEN 63005 AND 63011) OR 
                (GLAccount BETWEEN 63031 AND 63035) OR 
                (GLAccount BETWEEN 63025 AND 63030) OR
                (GLAccount BETWEEN 63015 AND 63023) OR

                /* G&A (GA / TGA) */
                (GLAccount = 65030) OR
                (GLAccount BETWEEN 65005 AND 65025) OR
                (GLAccount BETWEEN 65035 AND 65070) OR

                /* Misc Expenses (ME / TME) */
                (GLAccount IN (66020,66110,66005,66030,66105,66115,64999)) OR
                (GLAccount BETWEEN 66032 AND 66035) OR
                (GLAccount = 66003) OR
                (GLAccount BETWEEN 66010 AND 66016) OR
                (GLAccount BETWEEN 66021 AND 66026) OR
                (GLAccount BETWEEN 66036 AND 66100) OR
                (GLAccount BETWEEN 66200 AND 66900) OR

                /* Other Expenses (Income) — “36” in schedule */
                (GLAccount BETWEEN 70005 AND 70030) OR
                (GLAccount BETWEEN 71005 AND 71035)
            THEN GLActual ELSE 0 END),

    /* ------------------ Net Income Before G&A ------------------ */
    NetIncome_Before_GA =
        /* GP + Total Expenses (per schedule: GP + TE) */
        SUM(CASE WHEN
                (GLAccount BETWEEN 44005 AND 44006) OR
                (GLAccount BETWEEN 54005 AND 54006) OR
                (GLAccount IN (40020,50020,44007,54007)) OR
                (GLAccount BETWEEN 44010 AND 44011) OR
                (GLAccount BETWEEN 54010 AND 54011) OR
                (GLAccount = 44012) OR
                (GLAccount = 54012) OR
                (GLAccount BETWEEN 44013 AND 44015) OR
                (GLAccount BETWEEN 54013 AND 54015) OR
                (GLAccount BETWEEN 46005 AND 46006) OR
                (GLAccount BETWEEN 56005 AND 56007) OR
                (GLAccount = 56020) OR
                (GLAccount BETWEEN 46010 AND 46015) OR
                (GLAccount BETWEEN 56008 AND 56013) OR
                (GLAccount = 56015) OR
                (GLAccount BETWEEN 46035 AND 46036) OR
                (GLAccount = 56035) OR
                (GLAccount BETWEEN 46040 AND 46041) OR
                (GLAccount IN (46040,46041,56040,53110,56070,56095,40090,
                               56025,56080,56085,56016,56086,56090,53012))
            THEN GLActual ELSE 0 END)
        +
                SUM(CASE WHEN
                /* Employee Expenses (EE / TEE) */
                (GLAccount BETWEEN 61100 AND 61140) OR
                (GLAccount IN (61145,61146,61158,61161,61411,61415)) OR
                (GLAccount BETWEEN 61150 AND 61160) OR
                (GLAccount BETWEEN 61200 AND 61250) OR
                (GLAccount BETWEEN 61300 AND 61405) OR
                (GLAccount BETWEEN 61420 AND 61450) OR

                /* Occupancy Expenses (OE / TOE) */
                (GLAccount BETWEEN 62005 AND 62010) OR
                (GLAccount = 62055) OR
                (GLAccount BETWEEN 62015 AND 62050) OR
                (GLAccount = 62060) OR

                /* Vehicle Expenses (VE / TVE) */
                (GLAccount BETWEEN 63005 AND 63011) OR 
                (GLAccount BETWEEN 63031 AND 63035) OR 
                (GLAccount BETWEEN 63025 AND 63030) OR
                (GLAccount BETWEEN 63015 AND 63023) OR

                /* G&A (GA / TGA) */
                (GLAccount = 65030) OR
                (GLAccount BETWEEN 65005 AND 65025) OR
                (GLAccount BETWEEN 65035 AND 65070) OR

                /* Misc Expenses (ME / TME) */
                (GLAccount IN (66020,66110,66005,66030,66105,66115,64999)) OR
                (GLAccount BETWEEN 66032 AND 66035) OR
                (GLAccount = 66003) OR
                (GLAccount BETWEEN 66010 AND 66016) OR
                (GLAccount BETWEEN 66021 AND 66026) OR
                (GLAccount BETWEEN 66036 AND 66100) OR
                (GLAccount BETWEEN 66200 AND 66900) OR

                /* Other Expenses (Income) — “36” in schedule */
                (GLAccount BETWEEN 70005 AND 70030) OR
                (GLAccount BETWEEN 71005 AND 71035)
            
            THEN GLActual ELSE 0 END),

    /* ------------------ GP % ------------------ */
    GP_Percent =
        CASE
            WHEN SUM(CASE WHEN
                            (GLAccount BETWEEN 44005 AND 44006) OR
                            (GLAccount IN (40020, 44007)) OR
                            (GLAccount BETWEEN 44010 AND 44011) OR
                            (GLAccount = 44012) OR
                            (GLAccount BETWEEN 44013 AND 44015) OR
                            (GLAccount BETWEEN 46005 AND 46006) OR
                            (GLAccount BETWEEN 46010 AND 46015) OR
                            (GLAccount BETWEEN 46035 AND 46036) OR
                            (GLAccount BETWEEN 46040 AND 46041) OR
                            (GLAccount = 40090)
                        THEN GLActual ELSE 0 END) <> 0
            THEN
                1.0 *
                SUM(CASE WHEN
                        (GLAccount BETWEEN 44005 AND 44006) OR
                        (GLAccount BETWEEN 54005 AND 54006) OR
                        (GLAccount IN (40020,50020,44007,54007)) OR
                        (GLAccount BETWEEN 44010 AND 44011) OR
                        (GLAccount BETWEEN 54010 AND 54011) OR
                        (GLAccount = 44012) OR
                        (GLAccount = 54012) OR
                        (GLAccount BETWEEN 44013 AND 44015) OR
                        (GLAccount BETWEEN 54013 AND 54015) OR
                        (GLAccount BETWEEN 46005 AND 46006) OR
                        (GLAccount BETWEEN 56005 AND 56007) OR
                        (GLAccount = 56020) OR
                        (GLAccount BETWEEN 46010 AND 46015) OR
                        (GLAccount BETWEEN 56008 AND 56013) OR
                        (GLAccount = 56015) OR
                        (GLAccount BETWEEN 46035 AND 46036) OR
                        (GLAccount = 56035) OR
                        (GLAccount BETWEEN 46040 AND 46041) OR
                        (GLAccount IN (46040,46041,56040,53110,56070,56095,40090,
                                       56025,56080,56085,56016,56086,56090,53012))
                    THEN GLActual ELSE 0 END)
                / NULLIF(
                    SUM(CASE WHEN
                            (GLAccount BETWEEN 44005 AND 44006) OR
                            (GLAccount IN (40020, 44007)) OR
                            (GLAccount BETWEEN 44010 AND 44011) OR
                            (GLAccount = 44012) OR
                            (GLAccount BETWEEN 44013 AND 44015) OR
                            (GLAccount BETWEEN 46005 AND 46006) OR
                            (GLAccount BETWEEN 46010 AND 46015) OR
                            (GLAccount BETWEEN 46035 AND 46036) OR
                            (GLAccount BETWEEN 46040 AND 46041) OR
                            (GLAccount = 40090)
                        THEN GLActual ELSE 0 END), 0)
            ELSE NULL
        END
FROM GLData AS g
GROUP BY
    g.CSC,
    g.PostingMonth
ORDER BY
    g.CSC, g.PostingMonth;



---- kpi service 

-- Parameters (change as needed)
DECLARE @StartDate date = '2025-07-01';
DECLARE @EndDate   date = '2025-07-31';
DECLARE @ProfitCenter varchar(10) = '5';   -- CONSOLSERV

;WITH base AS (
    -- Aggregate GLActual by CSC & GLAccount (sign flipped like your sample)
    SELECT
        [Global Dimension 1 Code] AS CSC,
        [G_L Account No_]        AS GLAccount,
        GLActual = CAST(-SUM([Amount]) AS decimal(18,2))
    FROM [Production$G_L Entry]
    WHERE [Posting Date] >= @StartDate
      AND [Posting Date] <= @EndDate
      AND [Global Dimension 2 Code] = @ProfitCenter
      -- restrict to the 6 accounts used in GP / GP%
      AND [G_L Account No_] IN ('43010','43011','43008','40090','53010','53011')
    GROUP BY [Global Dimension 1 Code], [G_L Account No_]
),
w AS (
    SELECT
        b.CSC,
        b.GLAccount,
        b.GLActual,

        -- revenue only (43010, 43011) per CSC
        RevOnly =
            SUM(CASE WHEN b.GLAccount IN ('43010','43011')
                     THEN b.GLActual ELSE 0 END)
            OVER (PARTITION BY b.CSC),

        -- GP per CSC = (43010+43011+43008+40090) + (53011+53010)
        -- since base is already filtered to those 6 accounts, it's just the sum over the partition
        GP_All =
            SUM(b.GLActual) OVER (PARTITION BY b.CSC),

        -- order rows within each CSC
        Seq =
            ROW_NUMBER() OVER (
                PARTITION BY b.CSC
                ORDER BY CASE b.GLAccount
                           WHEN '43010' THEN 1
                           WHEN '43011' THEN 2
                           WHEN '43008' THEN 3
                           WHEN '40090' THEN 4
                           WHEN '53010' THEN 5
                           WHEN '53011' THEN 6
                           ELSE 99
                         END
            )
    FROM base b
)
SELECT
    w.CSC,
    w.GLAccount,
    w.GLActual,
    GP   = w.GP_All,
    [GP%] = CASE WHEN NULLIF(w.RevOnly,0) IS NULL
                 THEN NULL
                 ELSE 1.0 * w.GP_All / NULLIF(w.RevOnly,0)
            END
FROM w
ORDER BY w.CSC, w.Seq;


-----kpi service all records 

/* Gross Profit by CSC per Month (no date filter) */

WITH base AS (
    SELECT
        b.[Global Dimension 1 Code]          AS CSC,
        --b.[G_L Account No_]                  AS GLAccount,
        -- month bucket (first day of month) -> relate to your Date table on MonthStart
        CONVERT(date, DATEFROMPARTS(YEAR(b.[Posting Date]), MONTH(b.[Posting Date]), 1)) AS PostingDate,
        GLActual = CAST(-SUM(b.[Amount]) AS decimal(19,4))
    FROM [Production$G_L Entry] AS b
    WHERE b.[Global Dimension 2 Code] = '5'   -- ProfitCenter (CONSOLSERV). Change or parameterize if needed.
      AND b.[G_L Account No_] IN ('43010','43011','43008','40090','53010','53011')
    GROUP BY
        b.[Global Dimension 1 Code],
        --b.[G_L Account No_],
        DATEFROMPARTS(YEAR(b.[Posting Date]), MONTH(b.[Posting Date]), 1)
),
w AS (
    SELECT
        CSC,
        --GLAccount,
        PostingDate,
        GLActual,

        -- Revenue only (43010 + 43011) per CSC + month
        RevOnly = SUM(CASE WHEN GLAccount IN ('43010','43011') THEN GLActual ELSE 0 END)
                  OVER (PARTITION BY CSC, PostingDate),

        -- GP per CSC + month over the six accounts
        GP_All  = SUM(GLActual) OVER (PARTITION BY CSC, PostingDate),

        -- Row order inside each CSC + month
        Seq = ROW_NUMBER() OVER (
                PARTITION BY CSC, PostingDate
                ORDER BY CASE GLAccount
                           WHEN '43010' THEN 1
                           WHEN '43011' THEN 2
                           WHEN '43008' THEN 3
                           WHEN '40090' THEN 4
                           WHEN '53010' THEN 5
                           WHEN '53011' THEN 6
                           ELSE 99
                         END )
    FROM base
)
SELECT
    w.PostingDate,          -- month bucket (use your Date table to show month/year)
    w.CSC,
    --w.GLAccount,
    --w.GLActual,
    GP   = w.GP_All,
    [GP%] = CASE WHEN NULLIF(w.RevOnly, 0) IS NULL
                 THEN NULL
                 ELSE w.GP_All * 1.0 / NULLIF(w.RevOnly, 0)
            END
FROM w
where w.PostingDate > '2024-04-01'
ORDER BY w.PostingDate, w.CSC, w.Seq;



---service kpi only gp gp%

CREATE OR ALTER VIEW dbo.v_GL_GP_CSC AS
;WITH base AS (
    SELECT
        b.[Global Dimension 1 Code] AS CSC,
        b.[G_L Account No_]        AS GLAccount,
        CONVERT(date, DATEFROMPARTS(YEAR(b.[Posting Date]), MONTH(b.[Posting Date]), 1)) AS PostingDate,
        GLActual = CAST(-SUM(b.[Amount]) AS decimal(19,4))
    FROM [Production$G_L Entry] AS b
    WHERE b.[Global Dimension 2 Code] = '5'   -- ProfitCenter
      AND b.[G_L Account No_] IN ('43010','43011','43008','40090','53010','53011')
    GROUP BY
        b.[Global Dimension 1 Code],
        b.[G_L Account No_],
        DATEFROMPARTS(YEAR(b.[Posting Date]), MONTH(b.[Posting Date]), 1)
),
agg AS (
    SELECT
        PostingDate,
        CSC,
        GP      = SUM(GLActual),
        RevOnly = SUM(CASE WHEN GLAccount IN ('43010','43011') THEN GLActual ELSE 0 END)
    FROM base
    GROUP BY PostingDate, CSC
)
SELECT
    a.PostingDate,
    a.CSC,
    a.GP,
    [GP%] = CASE WHEN NULLIF(a.RevOnly, 0) IS NULL
                 THEN NULL
                 ELSE a.GP * 1.0 / NULLIF(a.RevOnly, 0)
            END
FROM agg AS a
where a.PostingDate > '2024-04-01';




---srevice kpi unified version 1

;WITH base AS (
    SELECT
        b.[Global Dimension 1 Code] AS CSC,
        -- Month bucket (first day of month). For daily, use: CAST(b.[Posting Date] AS date)
        CAST(DATEADD(month, DATEDIFF(month, 0, b.[Posting Date]), 0) AS date) AS PostingDate,

        -- Keep both string and integer versions of the account
        CAST(b.[G_L Account No_] AS varchar(20)) AS GLAccountStr,
        CASE 
            WHEN CAST(b.[G_L Account No_] AS varchar(20)) NOT LIKE '%[^0-9]%' 
                 THEN CAST(b.[G_L Account No_] AS int)
            ELSE NULL
        END AS GLAccountInt,

        GLActual = CAST(-SUM(b.[Amount]) AS decimal(19,4))
    FROM [Production$G_L Entry] AS b
    WHERE b.[Global Dimension 2 Code] = '5'   -- ProfitCenter: Service (CONSOLSERV)
    GROUP BY
        b.[Global Dimension 1 Code],
        DATEADD(month, DATEDIFF(month, 0, b.[Posting Date]), 0),
        b.[G_L Account No_]
),
sumper AS (
    SELECT
        PostingDate,
        CSC,

        -- 29: Total ALL Service Sales
        Sales29 =
            SUM(CASE
                    WHEN GLAccountInt like '4%'
                    THEN GLActual ELSE 0
                END),

        -- 30: Total ALL Service COGS
        COGS30 =
            SUM(CASE
                    WHEN GLAccountInt like '5%'
                    THEN GLActual ELSE 0
                END),

        -- Full Maintenance (6-account set)
        FM_Rev = SUM(CASE WHEN GLAccountInt IN (43010,43011) THEN GLActual ELSE 0 END),
        FM_All = SUM(CASE WHEN GLAccountInt IN (43010,43011,43008,40090,53010,53011) THEN GLActual ELSE 0 END),

        -- Total Operating Expense: accounts starting with 6, except 65200
        OpExp  = SUM(CASE WHEN (GLAccountInt BETWEEN 60000 AND 69999) AND GLAccountInt <> 65200
                          THEN GLActual ELSE 0 END)
    FROM base
    GROUP BY PostingDate, CSC
)
SELECT
    PostingDate,
    CSC,

    [Total ALL Service Sales] = Sales29,                           -- 29
    [Total ALL Service COGS]  = COGS30,                            -- 30
    [Total ALL Service GP]    = Sales29 + COGS30,                  -- 31
    [Total Service GP %]      = CASE WHEN Sales29 = 0 THEN NULL
                                     ELSE 1.0 * (Sales29 + COGS30) / Sales29 END,  -- R = 31/29

    [Full Maintenance GP]     = FM_All,
    [Full Maintenance GP %]   = CASE WHEN FM_Rev = 0 THEN NULL
                                     ELSE 1.0 * FM_All / FM_Rev END,

    [Total Operating Expense] = OpExp,
    [Total Service Expense %] = CASE WHEN Sales29 = 0 THEN NULL
                                     ELSE 1.0 * OpExp / Sales29 END,
     -- NEW: Operating Income = 31 | TE  (i.e., GP + OpEx)
    [Operating Income]        = (Sales29 + COGS30) + OpExp,

    -- NEW: Operating Income % = OI / 29
    [Operating Income %]      = CASE WHEN Sales29 = 0 THEN NULL
                                     ELSE 1.0 * ((Sales29 + COGS30) + OpExp) / Sales29 END
FROM sumper where PostingDate > '2024-01-01'
ORDER BY PostingDate, CSC;





--service kpi total service sales 


;WITH base AS (
    SELECT
        b.[Global Dimension 1 Code] AS CSC,
        -- Month bucket (first day of month). For daily use: CAST(b.[Posting Date] AS date)
        CAST(DATEADD(month, DATEDIFF(month, 0, b.[Posting Date]), 0) AS date) AS PostingDate,

        -- Keep both string and integer versions of the account
        CAST(b.[G_L Account No_] AS varchar(20)) AS GLAccountStr,
        CASE 
            WHEN CAST(b.[G_L Account No_] AS varchar(20)) NOT LIKE '%[^0-9]%' 
                 THEN CAST(b.[G_L Account No_] AS int)
            ELSE NULL
        END AS GLAccountInt,

        GLActual = CAST(-SUM(b.[Amount]) AS decimal(19,4))
    FROM [Production$G_L Entry] AS b
    WHERE b.[Global Dimension 2 Code] = '5'   -- ProfitCenter: Service (CONSOLSERV)
    GROUP BY
        b.[Global Dimension 1 Code],
        DATEADD(month, DATEDIFF(month, 0, b.[Posting Date]), 0),
        b.[G_L Account No_]
),
sumper AS (
    SELECT
        PostingDate,
        CSC,

        -- 29: Total ALL Service Sales (GLs starting with 4****)
        Sales29 =
            SUM(CASE
                    WHEN GLAccountInt BETWEEN 40000 AND 49999
                    THEN GLActual ELSE 0
                END),

        -- 30: Total ALL Service COGS (GLs starting with 5****)
        COGS30 =
            SUM(CASE
                    WHEN GLAccountInt BETWEEN 50000 AND 59999
                    THEN GLActual ELSE 0
                END),

        -- Full Maintenance set (for GP / GP%)
        FM_Rev = SUM(CASE WHEN GLAccountInt IN (43010,43011) THEN GLActual ELSE 0 END),
        FM_All = SUM(CASE WHEN GLAccountInt IN (43010,43011,43008,40090,53010,53011) THEN GLActual ELSE 0 END),

        -- Total Operating Expense: accounts starting with 6****, excluding 65200
        OpExp  = SUM(CASE WHEN (GLAccountInt BETWEEN 60000 AND 69999) AND GLAccountInt <> 65200
                          THEN GLActual ELSE 0 END)
    FROM base
    GROUP BY PostingDate, CSC
)
SELECT
    PostingDate,
    CSC,

    [Total ALL Service Sales] = Sales29,                           -- 29
    [Total ALL Service COGS]  = COGS30,                            -- 30
    [Total ALL Service GP]    = Sales29 + COGS30,                  -- 31
    [Total Service GP %]      = CASE WHEN Sales29 = 0 THEN NULL
                                     ELSE 1.0 * (Sales29 + COGS30) / Sales29 END,  -- R = 31/29

    [Full Maintenance GP]     = FM_All,
    [Full Maintenance GP %]   = CASE WHEN FM_Rev = 0 THEN NULL
                                     ELSE 1.0 * FM_All / FM_Rev END,

    [Total Operating Expense] = OpExp,

    -- NEW: Operating Income = 31 | TE  (i.e., GP + OpEx)
    [Operating Income]        = (Sales29 + COGS30) + OpExp,

    -- NEW: Operating Income % = OI / 29
    [Operating Income %]      = CASE WHEN Sales29 = 0 THEN NULL
                                     ELSE 1.0 * ((Sales29 + COGS30) + OpExp) / Sales29 END

FROM sumper
WHERE PostingDate > '2021-01-01'
ORDER BY PostingDate, CSC;
