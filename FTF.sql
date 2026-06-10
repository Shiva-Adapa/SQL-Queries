 -- QUERY CHECK 

    --final  4
    DECLARE @resp NVARCHAR(MAX); -- Declare the variable for Responsibility Center
DECLARE @servicetype NVARCHAR(MAX); -- Declare the variable for Service Type
DECLARE @fromPostDate DATE; -- Declare the variable for Starting Posting Date
DECLARE @thruPostDate DATE; -- Declare the variable for Ending Posting Date
-- Assign values to the variables
SET @resp = 'YourValue'; -- Assign the Responsibility Center filter value
SET @servicetype = 'YourServiceType'; -- Assign the Service Type filter value
SET @fromPostDate = '2024-01-01'; -- Example start date
SET @thruPostDate = '2024-12-31'; -- Example end date
-- Final Query
SELECT
    -- Columns from the first query
    Work_Order_Header.No_ AS Work_Order_HeaderNo_,
    Equipment_Object.No_ AS Equipment_ObjectNo_,
       [Production$Work Order Rep_ Lines].Line,
    [Production$Work Order Rep_ Lines].Description,
    Work_Order_Header.[Posting Date] AS Work_Order_HeaderPostingDate, 
    CASE Work_Order_Header.[Posting Status]
        WHEN 0 THEN 'Open' 
        WHEN 1 THEN 'Released' 
        WHEN 2 THEN 'Closed' 
        WHEN 3 THEN 'Lost Order' 
        ELSE '' 
    END AS Work_Order_HeaderPostingStatus, 
    Work_Order_Header.[Service Type] AS Work_Order_HeaderServiceType, 
    Work_Order_Header.[Responsibility Center] AS Work_Order_HeaderResponsibilityCenter, 
    Work_Order_Header.[Starting Date] AS Work_Order_HeaderStartingDate, 
    Work_Order_Header.[Finishing Date] AS Work_Order_HeaderFinishingDate, 
    CASE Work_Order_Header.[Priority] 
        WHEN 0 THEN ' ' 
        WHEN 3 THEN 'Low' 
        WHEN 6 THEN 'Medium' 
        WHEN 9 THEN 'High' 
        WHEN 12 THEN 'Critical' 
        ELSE '' 
    END AS Work_Order_HeaderPriority,
    (SELECT COUNT(*) 
     FROM [Production$Service Report] 
     WHERE [Work Order No_] = Work_Order_Header.No_ AND [Posting Status] = 1) AS Work_Order_HeaderServiceReportCountClosed, 
    Work_Order_Header.[Sell-to Customer No_], 
    Work_Order_Header.[Sell-to Customer Name], 
    WOL.No_ AS Resource,
    pwu.[Item No_],
    pwu.[Sell-to Customer No_] AS PartsWhereUsedSellToCustomerNo_,
    Production$Resource.[Service Van],
    MIN(CAST(PH.[Starting Date] AS DATE)) AS PH_FirstDate,
    MAX(CAST(PH.[Finishing Date] AS DATE)) AS PH_LastDate,
    SUM(PH.Hours) AS PH_WOHours,
    PH.[Responsibility Center] AS PH_ResponsibilityCenter,
    CASE 
        WHEN MIN(CAST(PH.[Starting Date] AS DATE)) = MAX(CAST(PH.[Finishing Date] AS DATE)) THEN 'Yes'
        ELSE 'NO'
    END AS Is_First_Time_Fix,
    -- Additional Columns from the second query
    [Production$Work Order Rep_ Lines].[Reporting Type],
 
    [Production$Rental Comment Line].[Comment Line No_],
    [Production$Rental Comment Line].Comment
FROM 
    [Production$Work Order Header] AS Work_Order_Header
LEFT OUTER JOIN 
    [Production$Equipment Object] AS Equipment_Object 
    ON Equipment_Object.No_ = Work_Order_Header.[Equipment Object]
LEFT OUTER JOIN 
    (SELECT 
         [Production$Hour Line].[Work Order No_], 
         MIN(CAST([Production$Hour Line].[Starting Date] AS DATE)) AS FirstDate, 
         MAX(CAST([Production$Hour Line].[Finishing Date] AS DATE)) AS LastDate, 
         SUM([Production$Hour Line].Hours) AS WOHours, 
         [Production$Hour Line].[Responsibility Center]
     FROM 
         [Production$Hour Line]
     INNER JOIN 
         [Production$Resource] 
         ON [Production$Hour Line].[Resource No_] = [Production$Resource].[No_]
     WHERE 
         [Production$Resource].[Job Title] <> 'TRUCK RETRIEVER'
     GROUP BY 
         [Production$Hour Line].[Work Order No_], 
         [Production$Hour Line].[Responsibility Center]
     HAVING 
         [Production$Hour Line].[Work Order No_] <> '' AND 
         [Production$Hour Line].[Responsibility Center] IN (@resp)
    ) AS TimeSheetHours 
    ON Work_Order_Header.No_ = TimeSheetHours.[Work Order No_]
LEFT JOIN 
    [Production$Work Order Line] AS WOL
    ON Work_Order_Header.No_ = WOL.[Document No_]
LEFT OUTER JOIN 
    [Production$Parts Where Used] AS pwu 
    ON pwu.[Document No_] = WOL.[Document No_]
LEFT JOIN 
    [Production$Hour Line] AS PH
    ON WOL.[Document No_] = PH.[Work Order No_]
LEFT JOIN 
    Production$Resource 
    ON WOL.No_ = Production$Resource.No_
    AND UPPER(Production$Resource.[Job Title]) NOT LIKE '%SHOP%'
LEFT JOIN 
    [Production$Work Order Rep_ Lines]
    ON Work_Order_Header.No_ = [Production$Work Order Rep_ Lines].[Document No_]
LEFT OUTER JOIN 
    [Production$Rental Comment Line] 
    ON [Production$Work Order Rep_ Lines].[Reporting Type] = [Production$Rental Comment Line].[Doc_ Line] 
    AND [Production$Work Order Rep_ Lines].[Document No_] = [Production$Rental Comment Line].[Doc No_]
WHERE 
    Work_Order_Header.[Posting Status] = 2 AND 
    Work_Order_Header.[Document Type] = 1 AND 
    (SELECT COUNT(*) 
     FROM [Production$Service Report] 
     WHERE [Work Order No_] = Work_Order_Header.No_ AND [Posting Status] = 1) > 0 AND 
    CAST(Work_Order_Header.[Posting Date] AS DATE) >= @fromPostDate AND 
    CAST(Work_Order_Header.[Posting Date] AS DATE) <= @thruPostDate AND
    (CAST(WOL.[Finishing Date] AS DATE) <= CAST(@thruPostDate AS DATE)) AND 
    (CAST(WOL.[Starting Date] AS DATE) >= DATEADD(month, -3, CAST(@fromPostDate AS DATE))) AND 
    (Production$Resource.[Job Title] <> 'TRUCK RETRIEVER') AND 
    (CAST(PH.[Starting Date] AS DATE) >= CAST(@fromPostDate AS DATE)) AND 
    (CAST(PH.[Finishing Date] AS DATE) <= CAST(@thruPostDate AS DATE)) AND 
    ([Production$Rental Comment Line].[Table Type] = 11021629 OR [Production$Rental Comment Line].[Table Type] IS NULL) AND 
    [Production$Work Order Rep_ Lines].[Reporting Type] = 3
    and Work_Order_Header.[Posting Date] ='2024-11-27'
    and Work_Order_Header.[Responsibility Center] ='4'
    AND Work_Order_Header.[Service Type] IN ('CDAMAGE-F', 'CDOCK', 'CFIELD', 'CRENT', 'CTMMI', 'CTMMIAB', 'CTMMINWT', 'CTMMK', 'CTMMKAB', 'FLEXRENTAL', 'MGOLD', 'MPLAT', 'MPLATAD', 'PWARR', 'RPO', 'RRENT', 'RRERENT', 'UAFTERS', 'USEDRENTAL', 'UWARR', 'WMFG')
GROUP BY 
    Work_Order_Header.No_,
    Equipment_Object.No_,
    Work_Order_Header.[Posting Date],
    Work_Order_Header.[Posting Status],
    Work_Order_Header.[Service Type],
    Work_Order_Header.[Responsibility Center],
    Work_Order_Header.[Starting Date],
    Work_Order_Header.[Finishing Date],
    Work_Order_Header.[Priority],
    Work_Order_Header.[Sell-to Customer No_],
    Work_Order_Header.[Sell-to Customer Name],
    TimeSheetHours.FirstDate,
    TimeSheetHours.LastDate,
    TimeSheetHours.WOHours,
    WOL.[Document No_],
    WOL.No_,
    pwu.[Item No_],
    pwu.[Sell-to Customer No_],
    Production$Resource.[Service Van],
    PH.[Work Order No_],
    PH.[Responsibility Center],
    [Production$Work Order Rep_ Lines].[Reporting Type],
    [Production$Work Order Rep_ Lines].Line,
    [Production$Work Order Rep_ Lines].Description,
    [Production$Rental Comment Line].[Comment Line No_],
    [Production$Rental Comment Line].Comment;




    -----DS1

    /*DECLARE @resp NVARCHAR(MAX); -- Declare the variable for Responsibility Center
DECLARE @servicetype NVARCHAR(MAX); -- Declare the variable for Service Type
DECLARE @fromPostDate DATE; -- Declare the variable for Starting Posting Date
DECLARE @thruPostDate DATE; -- Declare the variable for Ending Posting Date
--SET @resp = '6'; -- Assign the Responsibility Center filter value
--SET @servicetype = 'CFIELD'; -- Assign the Service Type filter value
--SET @fromPostDate = '2024-01-01'; -- Example start date
--SET @thruPostDate = '2024-12-31'; -- Example end date */
SELECT 
    Work_Order_Header.No_ AS Work_Order_HeaderNo_, 
    Equipment_Object.[No_],
    Work_Order_Header.[Posting Date] AS Work_Order_HeaderPostingDate, 
     CASE 
        WHEN TimeSheetHours.FirstDate=TimeSheetHours.LastDate THEN 'YES' 
        ELSE 'NO' 
    END AS IS_FIRSTTIME_FIX,
    CASE Work_Order_Header.[Posting Status]
        WHEN 0 THEN 'Open' 
        WHEN 1 THEN 'Released' 
        WHEN 2 THEN 'Closed' 
        WHEN 3 THEN 'Lost Order' 
        ELSE '' 
    END AS Work_Order_HeaderPostingStatus, 
    Work_Order_Header.[Service Type] AS Work_Order_HeaderServiceType, 
    Work_Order_Header.[Responsibility Center] AS Work_Order_HeaderResponsibilityCenter, 
    Work_Order_Header.[Starting Date] AS Work_Order_HeaderStartingDate, 
    Work_Order_Header.[Finishing Date] AS Work_Order_HeaderFinishingDate, 
    CASE Work_Order_Header.[Priority] 
        WHEN 0 THEN ' ' 
        WHEN 3 THEN 'Low' 
        WHEN 6 THEN 'Medium' 
        WHEN 9 THEN 'High' 
        WHEN 12 THEN 'Critical' 
        ELSE '' 
    END AS Work_Order_HeaderPriority,
    (SELECT COUNT(*) 
     FROM [Production$Service Report] 
     WHERE [Work Order No_] = Work_Order_Header.No_ AND [Posting Status] = 1) AS Work_Order_HeaderServiceReportCountClosed, 
    Work_Order_Header.[Sell-to Customer No_], 
    Work_Order_Header.[Sell-to Customer Name], 
    TimeSheetHours.FirstDate, 
    TimeSheetHours.LastDate, 
    TimeSheetHours.WOHours
FROM 
    [Production$Work Order Header] AS Work_Order_Header
INNER JOIN 
    [Production$Equipment Object] AS Equipment_Object 
    ON Equipment_Object.No_ = Work_Order_Header.[Equipment Object]
LEFT OUTER JOIN 
    (SELECT 
         [Production$Hour Line].[Work Order No_], 
         MIN(CAST([Production$Hour Line].[Starting Date] AS DATE)) AS FirstDate, 
         MAX(CAST([Production$Hour Line].[Finishing Date] AS DATE)) AS LastDate, 
         SUM([Production$Hour Line].Hours) AS WOHours, 
         [Production$Hour Line].[Responsibility Center]
     FROM 
         [Production$Hour Line]
     INNER JOIN 
         [Production$Resource] 
         ON [Production$Hour Line].[Resource No_] = [Production$Resource].[No_]
     WHERE 
         [Production$Resource].[Job Title] <> 'TRUCK RETRIEVER'
     GROUP BY 
         [Production$Hour Line].[Work Order No_], 
         [Production$Hour Line].[Responsibility Center]
     HAVING 
         [Production$Hour Line].[Work Order No_] <> '' 
         --AND 
         --[Production$Hour Line].[Responsibility Center] IN (@resp)
    ) AS TimeSheetHours 
    ON Work_Order_Header.No_ = TimeSheetHours.[Work Order No_]
WHERE 
    Work_Order_Header.[Posting Status] = 2 AND 
    Work_Order_Header.[Document Type] = 1 AND 
    (SELECT COUNT(*) 
     FROM [Production$Service Report] 
     WHERE [Work Order No_] = Work_Order_Header.No_ AND [Posting Status] = 1) > 0 
   and Work_Order_Header.[Posting Date] BETWEEN '2024-01-01' AND '2024-12-31'
    --and Work_Order_Header.[Responsibility Center] ='1'
    AND Work_Order_Header.[Service Type] IN ('CDAMAGE-F', 'CDOCK', 'CFIELD', 'CRENT', 'CTMMI', 'CTMMIAB', 'CTMMINWT', 'CTMMK', 'CTMMKAB', 'FLEXRENTAL', 'MGOLD', 'MPLAT', 'MPLATAD', 'PWARR', 'RPO', 'RRENT', 'RRERENT', 'UAFTERS', 'USEDRENTAL', 'UWARR', 'WMFG')

    --Work_Order_Header.[Service Type] IN (@servicetype) AND 
    --Work_Order_Header.[Responsibility Center] IN (@resp) AND 
    --CAST(Work_Order_Header.[Posting Date] AS DATE) >= @fromPostDate AND 
    --CAST(Work_Order_Header.[Posting Date] AS DATE) <= @thruPostDate;

-- data set 2 

SELECT 
    [Production$Work Order Header].No_, 
    [Production$Work Order Header].[Sell-to Customer No_], 
    [Production$Work Order Rep_ Lines].[Reporting Type], 
    [Production$Work Order Rep_ Lines].Line, 
    [Production$Work Order Rep_ Lines].Description, 
    [Production$Rental Comment Line].[Comment Line No_], 
    [Production$Rental Comment Line].Comment
FROM 
    [Production$Work Order Header]
INNER JOIN 
    [Production$Work Order Rep_ Lines] 
    ON [Production$Work Order Header].No_ = [Production$Work Order Rep_ Lines].[Document No_]
LEFT OUTER JOIN 
    [Production$Rental Comment Line] 
    ON [Production$Work Order Rep_ Lines].[Reporting Type] = [Production$Rental Comment Line].[Doc_ Line] 
    AND [Production$Work Order Rep_ Lines].[Document No_] = [Production$Rental Comment Line].[Doc No_]
WHERE 
    [Production$Work Order Header].[Document Type] = 1 
    AND [Production$Work Order Header].[Posting Status] = 2
    AND ([Production$Rental Comment Line].[Table Type] = 11021629 OR [Production$Rental Comment Line].[Table Type] IS NULL)
    AND [Production$Work Order Rep_ Lines].[Reporting Type] = 3
    AND CAST([Production$Work Order Header].[Posting Date] AS DATE) >= '2025-01-01'
    AND CAST([Production$Work Order Header].[Posting Date] AS DATE) <= '2025-12-31'
    AND [Production$Work Order Header].No_= 'S2755354'
    ;

-- Comments concatinated 

SELECT 
    h.No_ AS [Work Order No],
    h.[Sell-to Customer No_],
    STUFF((
        SELECT ' | ' + rc2.Comment
        FROM [Production$Work Order Rep_ Lines] AS r2
        LEFT JOIN [Production$Rental Comment Line] AS rc2 
            ON r2.[Reporting Type] = rc2.[Doc_ Line] 
            AND r2.[Document No_] = rc2.[Doc No_]
        WHERE 
            r2.[Document No_] = h.No_
            AND (rc2.[Table Type] = 11021629 OR rc2.[Table Type] IS NULL)
            AND r2.[Reporting Type] = 3
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
    , 1, 3, '') AS All_Comments
FROM 
    [Production$Work Order Header] AS h
WHERE 
    h.[Document Type] = 1 
    AND h.[Posting Status] = 2
    AND CAST(h.[Posting Date] AS DATE) BETWEEN '2025-01-01' AND '2025-12-31'
    AND h.No_ = 'S2755354'

-- optimized query for comments 

SELECT 
    h.No_ AS [Work Order No],
    h.[Sell-to Customer No_],
    Comments.CommentText AS All_Comments
FROM 
    [Production$Work Order Header] AS h
OUTER APPLY (
    SELECT 
        STUFF((
            SELECT ' | ' + rc.Comment
            FROM [Production$Work Order Rep_ Lines] AS r
            LEFT JOIN [Production$Rental Comment Line] AS rc 
                ON r.[Reporting Type] = rc.[Doc_ Line] 
                AND r.[Document No_] = rc.[Doc No_]
            WHERE 
                r.[Document No_] = h.No_
                AND (rc.[Table Type] = 11021629 OR rc.[Table Type] IS NULL)
                AND r.[Reporting Type] = 3
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
        , 1, 3, '') AS CommentText
) AS Comments
WHERE 
    h.[Document Type] = 1 
    AND h.[Posting Status] = 2
    AND CAST(h.[Posting Date] AS DATE) BETWEEN '2025-01-01' AND '2025-12-31'
   AND h.No_ = 'S2975871'


    --resource table 

    SELECT  WOL.[Document No_], WOL.No_ AS Techs, Production$Resource.[Name],Production$Resource.[Service Van]
FROM     [Production$Work Order Line] AS WOL INNER JOIN
                  Production$Resource ON WOL.No_ = Production$Resource.No_ AND UPPER(Production$Resource.[Job Title]) NOT LIKE '%SHOP%'
WHERE  (WOL.Type = 2) AND (WOL.[Document Type] = 1)  AND (CAST(WOL.[Finishing Date] AS DATE) <= '2024-12-31') AND 
                  (CAST(WOL.[Starting Date] AS DATE) >= '2024-01-01')
GROUP BY WOL.[Document No_], WOL.No_,Production$Resource.[Service Van],Production$Resource.[Name]

select top 100 * from Production$Resource


SELECT top 10 *
     FROM [Production$Service Report] 
      --[Posting Status] = '1'


SELECT        [Responsibility Center], [Creation Datetime], [Document User ID], No_, [From Quote], [Contract Type], [Sell-to Customer No_], [Sell-to Customer Name], FORMAT([Starting Date], 'MM/dd/yyyy') AS [Starting Date], 
                         FORMAT([Finishing Date], 'MM/dd/yyyy') AS [Finishing Date]
FROM            [Production$Rental Contract Header]
WHERE        ([Creation Datetime] >= DATEADD(month, - 1, DATEADD(month, DATEDIFF(month, 0, CURRENT_TIMESTAMP), 0))) AND ([Creation Datetime] < DATEADD(month, DATEDIFF(month, 0, CURRENT_TIMESTAMP), 0)) AND 
                         ([Document Type] = 1) AND ([Contract Type] NOT IN ('LEASESAMED', 'PRLFTFIN', 'LEASETFS', 'LEASETFSGM'))