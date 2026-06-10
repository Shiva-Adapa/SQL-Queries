/*
 * Jstenstrom query for Fever report
 */
DECLARE @FYStart DATE
DECLARE @FYEnd DATE
-- Calculate fiscal year based on April to March
SET @FYStart = CASE WHEN MONTH(GETDATE()) >= 4 
                    THEN CAST(CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-04-01' AS DATE)
                    ELSE CAST(CAST(YEAR(GETDATE())-1 AS VARCHAR(4)) + '-04-01' AS DATE)
                    END
SET @FYEnd = DATEADD(DAY, -1, DATEADD(YEAR, 1, @FYStart))
SELECT 
	mch.[Responsibility Center] [CSC],
	mch.[Preferred Resource No_] [Tech],
	psp.Name [Sales Rep Name],
	mch.[Sell-to Customer No_] [Customer No.],
	EO.[Customer Name] [Sell-to Customer Name],
	mch.[No_] [Document No.],
	mch.[Contract Type] [Type],
	CASE
		mch.[Invoice Period] WHEN 0 THEN 'Month(Calendar)' -- Single billing Month
		WHEN 1 THEN 'Two Months'
		WHEN 2 THEN 'Three Months'
		WHEN 3 THEN 'Six Months'
		WHEN 4 THEN 'Twelve Months'
		WHEN 5 THEN 'Month(+1M)' -- ReOccurring monmthly billing
		WHEN 6 THEN 'Schedule' -- Custom Billing Cycle
		WHEN 7 THEN 'Quarter'
		WHEN 8 THEN 'Half Year'
		WHEN 9 THEN 'Year'
		ELSE ''
	END [Invoice Period],
	EO.No_ [Equipment Object],
	EO.[Equipment Model] [Model],
	EO.[Serial No_] [Serial No.],
	EO.[Equipment Category],
	EO.[Equipment Group],
	EO.[M1] [Actual M1],
	CAST(EO.[Last Meter Reading M1] AS DATE)[Last Meter Reading],
	CAST(mch.[Starting Date] AS DATE) AS MC_Startdate,
	CAST(mch.[Finishing Date] AS DATE) AS MC_FinishDate,
	CAST(mcl.[Starting Date] AS DATE) AS MCL_StartDate,
	CAST(mcl.[Finishing Date] AS DATE) AS MCL_FinishDate,
	DATEDIFF(m,GETDATE(),CAST(mcl.[Finishing Date] AS DATE))[Months Left],
	DATEDIFF(m,CAST(mcl.[Starting Date] AS DATE),GETDATE())[Months Amassed],	
	CAST(mcl.[Annual Amount] AS DECIMAL(38,	2))/ 12 AS [Monthly Rate],
	mch.[Document Type],	
	SUM(CASE 
            WHEN eve.[Entry Type] = 44 AND eve.[Posting Date] BETWEEN @FYStart AND @FYEnd
            THEN eve.Amount
            ELSE 0
        END) AS [Fiscal YTD Invoiced],
		SUM(CASE 
            WHEN eve.[Entry Type] = 43 AND eve.[Posting Date] BETWEEN @FYStart AND @FYEnd
            THEN eve.Amount
            ELSE 0
        END) AS [Fiscal YTD Claims],
		SUM(CASE 
            WHEN eve.[Entry Type] = 46 AND eve.[Posting Date] BETWEEN @FYStart AND @FYEnd
            THEN eve.Amount
            ELSE 0
        END) AS [Fiscal YTD OT],
	SUM(CASE WHEN eve.[Entry Type] = 44 THEN eve.Amount END) [Contract LTD Invoiced],
	SUM(CASE WHEN eve.[Entry Type] = 43 THEN eve.Amount END) [Contract LTD Claims],
	SUM(CASE WHEN eve.[Entry Type] = 46 THEN eve.Amount END) [Contract LTD OT]	
FROM
	[Production$Maintenance Contract Header] mch
LEFT JOIN [Production$Maintenance Contract Line] mcl ON
	mch.No_ = mcl.[Document No_] AND mch.[Document Type] = mcl.[Document Type]
LEFT JOIN [Production$Equipment Object] EO ON
	mcl.[Equipment Object] = EO.No_
LEFT JOIN [Production$Equipment Value Entry] eve ON eve.[Equipment Object] = mcl.[Equipment Object] 
												AND eve.[Contract No_] = mch.No_ 
												AND eve.[Contract Type] = 1 --Maintenance Contract
LEFT JOIN [Production$Salesperson_Purchaser] psp on
	mch.[Order Manager] = psp.Code
WHERE mch.[Contract Type] IN ('GOLD', 'SILVER', 'PLATINUM')
AND mch.[Document Type] = 1 -- Contract
	AND EO.No_ = 'E201785' --Test line
	AND mcl.[Finishing Date] > GETDATE()
	AND mcl.Status = 1 --released
GROUP BY mch.[Responsibility Center],
	mch.[Preferred Resource No_],
	psp.Name,
	mch.[Sell-to Customer No_],
	EO.[Customer Name],
	mch.[No_],
	mch.[Contract Type],
	CASE
		mch.[Invoice Period] WHEN 0 THEN 'Month(Calendar)' -- Single billing Month
		WHEN 1 THEN 'Two Months'
		WHEN 2 THEN 'Three Months'
		WHEN 3 THEN 'Six Months'
		WHEN 4 THEN 'Twelve Months'
		WHEN 5 THEN 'Month(+1M)' -- ReOccurring monmthly billing
		WHEN 6 THEN 'Schedule' -- Custom Billing Cycle
		WHEN 7 THEN 'Quarter'
		WHEN 8 THEN 'Half Year'
		WHEN 9 THEN 'Year'
		ELSE ''
	END,
	EO.No_,
	EO.[Equipment Model],
	EO.[Serial No_],
	EO.[Equipment Category],
	EO.[Equipment Group],
	EO.[M1],
	CAST(EO.[Last Meter Reading M1] AS DATE),
	CAST(mch.[Starting Date] AS DATE) ,
	CAST(mch.[Finishing Date] AS DATE) ,
	CAST(mcl.[Starting Date] AS DATE) ,
	CAST(mcl.[Finishing Date] AS DATE) ,
	DATEDIFF(m,GETDATE(),CAST(mcl.[Finishing Date] AS DATE)),
	DATEDIFF(m,CAST(mcl.[Starting Date] AS DATE),GETDATE()),
	CAST(mcl.[Annual Amount] AS DECIMAL(38,	2))/ 12,
	mch.[Document Type]
	;