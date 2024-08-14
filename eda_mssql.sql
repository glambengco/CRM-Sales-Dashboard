

/* Quarterly Sales by Manager */

-- 2017 Q4 total sales average sale value and days to close by manager
SELECT
	manager, 
	SUM(close_value) AS Total_Sales,
	AVG(close_value) AS Average_Sale_Value
FROM sales_pipeline AS sp
RIGHT JOIN sales_teams AS st
ON sp.sales_agent = st.sales_agent
WHERE 
	deal_stage ='Won'
	AND YEAR(close_date) = 2017
	AND DATEPART(QUARTER, close_date) = 4
GROUP BY manager
ORDER BY Total_Sales DESC
GO


-- 2017 Q4 win rates by amanger
WITH SourceTable AS (
	SELECT opportunity_id, manager, deal_stage
	FROM sales_pipeline AS sp
	RIGHT JOIN sales_teams AS st
	ON sp.sales_agent = st.sales_agent
	WHERE 
		YEAR(close_date) = 2017
		AND DATEPART(QUARTER, close_date) = 4
)
SELECT
	manager, 
	[Won], [Lost], 
	CAST([Won] AS FLOAT) / ([Won] + [Lost]) * 100 AS Win_Rate
FROM SourceTable
PIVOT(
	COUNT(opportunity_id) FOR deal_stage IN ([Won], [Lost])
) AS PivotTable
ORDER BY Win_Rate DESC
GO


-- 2017 Q4 average days to close by manager
SELECT
	manager,
	AVG(
		CAST(
			DATEDIFF(DAY, engage_date, close_date) 
			AS FLOAT
		)
	) AS Average_Days_To_Close
FROM sales_pipeline AS sp
RIGHT JOIN sales_teams AS st
ON sp.sales_agent = st.sales_agent
WHERE 
	close_date IS NOT NULL
	AND YEAR(close_date) = 2017
	AND DATEPART(QUARTER, close_date) = 4
GROUP BY manager
ORDER BY Average_Days_To_Close
GO

/* Quarterly sales by sales agent */

-- 2017 Q4 sales by sales agent
SELECT
	st.sales_agent AS agent, 
	manager,
	SUM(close_value) AS Total_Sales,
	AVG(close_value) AS Average_Sale_Value
FROM sales_pipeline AS sp
RIGHT JOIN sales_teams AS st
ON sp.sales_agent = st.sales_agent
WHERE 
	deal_stage ='Won'
	AND YEAR(close_date) = 2017
	AND DATEPART(QUARTER, close_date) = 4
GROUP BY manager, st.sales_agent
ORDER BY Total_Sales DESC
GO


-- 2017 Q4 win rates by sales agent
WITH SourceTable AS (
	SELECT opportunity_id, st.sales_agent, manager, deal_stage
	FROM sales_pipeline AS sp
	RIGHT JOIN sales_teams AS st
	ON sp.sales_agent = st.sales_agent
	WHERE 
		YEAR(close_date) = 2017
		AND DATEPART(QUARTER, close_date) = 4
)
SELECT
	manager, 
	sales_agent,
	[Won], [Lost], 
	CAST([Won] AS FLOAT) / ([Won] + [Lost]) * 100 AS Win_Rate
FROM SourceTable
PIVOT(
	COUNT(opportunity_id) FOR deal_stage IN ([Won], [Lost])
) AS PivotTable
ORDER BY Win_Rate DESC
GO


-- 2017 Q4 average days to close by sales agent
SELECT
	manager,
	st.sales_agent,
	AVG(
		CAST(
			DATEDIFF(DAY, engage_date, close_date) 
			AS FLOAT
		)
	) AS Average_Days_To_Close
FROM sales_pipeline AS sp
RIGHT JOIN sales_teams AS st
ON sp.sales_agent = st.sales_agent
WHERE 
	close_date IS NOT NULL
	AND YEAR(close_date) = 2017
	AND DATEPART(QUARTER, close_date) = 4
GROUP BY manager, st.sales_agent
ORDER BY Average_Days_To_Close
GO

/* Sales opportunities */
SELECT
	opportunity_id, 
	sp.product,
	account,
	sp.sales_agent,
	manager,
	engage_date,
	sales_price AS Potential_Sale_Value
FROM sales_pipeline AS sp
LEFT JOIN sales_teams AS st
ON sp.sales_agent = st.sales_agent
LEFT JOIN products AS pr
ON sp.[product] = pr.[product]
WHERE deal_stage = 'Engaging'
ORDER BY Potential_Sale_Value DESC
GO

/* Sales by region, industry, and product */

-- 2017 Q4 sales by region
SELECT 
	office_location AS Region,
	SUM(close_value) AS Total_Sales
FROM sales_pipeline AS sp
LEFT JOIN accounts AS ac
ON sp.account = ac.account
WHERE
	deal_stage = 'Won'
	AND YEAR(close_date) = 2017
	AND DATEPART(QUARTER, close_date) = 4
GROUP BY office_location
ORDER BY Total_Sales DESC
GO


-- 2017 Q4 sales by industry
SELECT 
	sector AS Industry,
	SUM(close_value) AS Total_Sales
FROM sales_pipeline AS sp
LEFT JOIN accounts AS ac
ON sp.account = ac.account
WHERE
	deal_stage = 'Won'
	AND YEAR(close_date) = 2017
	AND DATEPART(QUARTER, close_date) = 4
GROUP BY sector
ORDER BY Total_Sales DESC
GO

-- 2017 Q4 sales by product
WITH product_sales_cte AS (
	SELECT 
	[product], 
	close_value,
	CASE
		WHEN deal_stage = 'Won' THEN 1
		ELSE 0
	END AS Win
	FROM sales_pipeline AS sp
	WHERE
		close_date IS NOT NULL
		AND YEAR(close_date) = 2017
		AND DATEPART(QUARTER, close_date) = 4
)
SELECT 
	[product], 
	SUM(close_value) AS Total_Sales,
	SUM(Win) AS Wins,
	AVG(CAST(Win AS FLOAT))*100 AS Win_Rate
FROM product_sales_cte
GROUP BY [product]
ORDER BY Total_Sales DESC
GO


/* Sales over Time */
WITH qtr_sales_by_manager AS (
	SELECT
		DATEPART(QUARTER, close_date) AS 'Qtr',
		manager,
		SUM(close_value) AS Total_Sales
	FROM sales_pipeline AS sp
	LEFT JOIN sales_teams AS st
	ON sp.sales_agent = st.sales_agent
	WHERE YEAR(close_date) = 2017
	GROUP BY DATEPART(QUARTER, close_date), manager
)
SELECT *,
	AVG(Total_Sales) OVER(PARTITION BY Qtr) AS 'Company_Average',
	RANK() OVER(PARTITION BY Qtr ORDER BY Total_Sales DESC) AS 'Rank'
FROM qtr_sales_by_manager
ORDER BY Qtr, Total_Sales DESC
GO