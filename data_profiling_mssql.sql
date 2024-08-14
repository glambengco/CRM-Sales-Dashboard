/* Data Profiling of the CRM Sales Opportunities dataset
The four tables was imported to a database in Microosft SQL Server to better 
simulate a real-world data infrastructure.
Data profiling wwas performed to identify relevant data and potential anomalies, outliers, 
or other data quality issues that needs to be handled prior to exploratory data analysis.

IMPORTANT NOTE: This script uses Transact-SQL, which is fully compatible only 
with Microsoft SQL Server.
*/

/* PART 1. Sales Pipeline */

-- Count the number of transaction records
SELECT COUNT(DISTINCT opportunity_id)
FROM sales_pipeline;
-- There are 8800 sales opportunity records.
GO


-- Display distinct sales agents
SELECT DISTINCT sales_agent
FROM sales_pipeline;
-- There are 30 distinct sales agents and no missing values.
GO


-- Display distinct products
SELECT DISTINCT product
FROM sales_pipeline;
-- There are 7 distinct products and no missing values.
GO


-- Display distinct accounts
SELECT DISTINCT account
FROM sales_pipeline;
-- There are 85 distinct accounts. Some rows have missing 
-- account values and need to be investigated later.
GO


-- Count missing account values
SELECT COUNT(*)
FROM sales_pipeline
WHERE account IS NULL;
-- There are 1425 missing account values.
GO


--Display number of opportunities by deal stage
SELECT deal_stage, COUNT(*) AS 'count'
FROM sales_pipeline
GROUP BY deal_stage;
/*
deal_stage	count
Lost	    2473
Engaging	1589
Prospecting	500
Won	        4238
*/
-- There are no missing values and the distibution of counts seem normal.
GO


-- Display range of engage_date
SELECT 
	MIN(engage_date) AS 'earliest',
	MAX(engage_date) AS 'latest'
FROM sales_pipeline;
-- Earliest is 2016-10-20 and latest is 2016-10-20
GO


-- Checck for null values in engage_date
SELECT COUNT(*)
FROM sales_pipeline
WHERE engage_date IS NULL;
-- There are 500 missing values.
GO


-- A quick look at the records with missing engage_date
SELECT *
FROM sales_pipeline
WHERE engage_date IS NULL
-- All records with missiing engage_date are on the prospecting stage  
-- with no close date and close value.
GO


-- Display range of close_date
SELECT 
	MIN(close_date) AS 'earliest', 
	MAX(close_date) AS 'latest'
FROM sales_pipeline;
-- Earliest is 2017-03-01, latest is 2017-12-31
GO


-- Count missing close_date values
SELECT COUNT(*)
FROM sales_pipeline
WHERE close_date IS NULL;
-- There are 2089 missing values.This is equal to the 
-- total number of prospecting and engaging stage opportunities.
GO


-- Display statistics of close_value
SELECT
	MIN(close_value) AS 'min',
	AVG(close_value) AS 'average',
	MAX(close_value) AS 'max'
FROM sales_pipeline;
-- Minimum is 0. Further investigate the reason for this value.
-- Average is 1490 and max is 30288, which seem normal.
GO


-- Count missing values for close_value
SELECT COUNT(*)
FROM sales_pipeline
WHERE close_value IS NULL;
-- There are 2089 missing values - same as close_date.
GO


SELECT deal_stage, COUNT(*)
FROM sales_pipeline
WHERE account IS NULL
GROUP BY deal_stage
-- 337 records are in thhe prospecting stage. These sales agents are  actively looking
-- for clients to engage. 163 of the 500 prospecting stage records have account values.
-- 1088 records are in the engaging stage. 
GO


/* Observations
Although there are several missing values in the sales_pipeline table, all of thee
missing values makes sense in the business context and does not affect the quality
of the data. Therefore, these missing values will be left as is.
*/

/* PART 2. Other Tables */

-- Count the distinct account values
SELECT COUNT(account)
FROM accounts;
-- There are 85 distinct accounts
GO


-- Inspect the whole table
SELECT *
FROM accounts;
-- Since the table only has 85 rows and 7 columns, visually inspecting the table was done.
-- The parent company column has several missing values. This makes sense since not all
-- companies are subsidiaries; moreover, this column is not relevant to the project.
GO


-- Inspect the products table
SELECT *
FROM products;
-- There are 3 series with a total of 7 products.
-- The product "GTX Pro" is misspelled as "GTXPro" in the sales_pipeline table. This needs to be corrected.
GO


-- Replace "GTXPro" with "GTX Pro" in sales_pipeline table.
UPDATE sales_pipeline
SET [product] = 'GTX Pro'
WHERE [product] = 'GTXPro'
-- 1480 rows were affected.
GO


-- Confirm the changes made.
SELECT DISTINCT [product]
FROM sales_pipeline
GO


-- Group sales teams by regional office
SELECT 
	regional_office, 
	COUNT(DISTINCT manager) AS 'manager_count',
	COUNT(DISTINCT sales_agent) AS 'sales_agent_count'
FROM sales_teams
GROUP BY regional_office
-- There are 3 egional offices:
-- Central has 2 managers and total of 11 sales agents, 
-- East and West both have 2 managers and 12 sales agents.
-- Total numbewr of sales agents is 35, which is more than the number 
-- of distinct sales agents in the sales_pipeline table.
GO


-- Check if sales agent names appear on both sales_pipeline and sales_teams tables.
SELECT 
	DISTINCT st.sales_agent AS sales_agent, 
	CASE
		WHEN sp.sales_agent IS NULL THEN 'No' 
		ELSE 'Yes'
	END
	AS in_sales_pipeline,
	manager,
	regional_office
FROM sales_pipeline AS sp
FULL JOIN sales_teams AS st
ON sp.sales_agent = st.sales_agent
ORDER BY in_sales_pipeline;
-- There are 5 sales agents that were not in the sales pipeline table. 
GO


/* Observations
As there is no additional data to explain the discrepancy in distinct sales agents 
values between the sales_pipeline and sales_teams tables, an assumption is made that
these sales agents are newly recruited and have not started prospecting opportunities.
Besides the mentioned issue, all values from the three tables seem normal.
*/


/* Conclusion
While the dataset contains several missing values, these are expected and should be left as is. 
The product column of sales pipeline was cleaned to fix spelling inconsistencies with the products table.
The four tables are of adequate quality and ready for data exploration.
*/