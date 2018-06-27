/************************************   PART 1    ********************************************/


USE AdventureWorks10;

-- Check available data source columns

EXEC sp_help 'Production.TransactionHistory';

-- See all the data in that table.  

SELECT * from [Production].[TransactionHistory];

-- Select * not recommended in your application queries.  Why?

SELECT 	[ProductID],	
		[Quantity],
		[TransactionDate]
FROM	[Production].[TransactionHistory];


-- SELECT Statement with literal value, no data source access. 

SELECT	'1' AS [col01],
		'A' AS [col02]

-- Adding a literal value to to result set.  Also adding an expression to form new calculated column result as 'TotalCost'

SELECT	[TransactionID],	
		[ProductID],	
		[Quantity],
		[ActualCost],
		'Batch 1' AS [BatchID],
		([Quantity] * [ActualCost]) as [TotalCost]
FROM [Production].[TransactionHistory];


/* Regular versus Delimited Identifiers  (Identifiers are the object names or tables, columns, etc).
   Regular identifies conform to certain naming rules, such as no spaces, no reserved words, limited special characters
*/

CREATE TABLE #Department
	( [Department ID] int NOT NULL);

-- the following will error
SELECT Department ID FROM #Department

-- the following will work
SELECT [Department ID] FROM #Department



-- Table Aliases

SELECT   [d].[Name] from [HumanResources].[Department] as [d];


SELECT	[TransactionID],	
		[ProductID],	
		[Quantity],
		[ActualCost],
		'Batch 1' AS [BatchID],
		([Quantity] * [ActualCost]) as [TotalCost]
FROM [Production].[TransactionHistory]
ORDER BY [ProductID], [Quantity];





/* WHERE Clause to limit result set by specified criteria */

SELECT	[TransactionID],	
		[ProductID],	
		[Quantity],
		[ActualCost],
		'Batch 1' AS [BatchID],
		([Quantity] * [ActualCost]) as [TotalCost]
FROM [Production].[TransactionHistory] as T
WHERE T.Quantity > 1
	AND T.ActualCost > 0
ORDER BY [ProductID], [Quantity];


/* DISTINCT Clause to eliminate duplicate rows - notice the difference between the following 2 queries */

SELECT [ProductID],	
		[Quantity]
FROM [Production].[TransactionHistory]
WHERE [ProductID] = 784 ORDER BY Quantity;

SELECT DISTINCT [ProductID],	
		[Quantity]
FROM [Production].[TransactionHistory]
WHERE [ProductID] = 784 ORDER BY Quantity;



/* GROUP BY allows for aggregation of data based on specified criteria
*/

--	First show all of the different sales prices for product id 377

SELECT ProductID, ActualCost
FROM [Production].[TransactionHistory]
where productid = 377
order by productId, ActualCost;

-- what if you want the average sales price of this product  (41.824)

SELECT AVG(ActualCost) 
FROM [Production].[TransactionHistory]
where productid = 377;


-- now what if you want the average sales price of ALL the products - USE GROUP BY

SELECT ProductID, AVG(ActualCost) 
FROM [Production].[TransactionHistory]
GROUP BY ProductID
ORDER BY ProductID;


/* Column Identifiers
-- next add the "AS AvgSalePrice" column identifier
*/

SELECT ProductID, AVG(ActualCost) AS [AverageActualCost]
FROM [Production].[TransactionHistory]
GROUP BY ProductID
ORDER BY ProductID;


/* BINDING ORDER:   The clauses of Transaction SQL Statements are logically processed in the following order: 
		FROM
		ON
		JOIN
		WHERE
		GROUP BY
		WITH CUBE/ROLLUP
		HAVING
		SELECT
		DISTINCT
		ORDER BY
		TOP
		OFFSET/FETCH
*/
-- can I reference TotalCost in the WHERE clause in the following statement?  

SELECT [TransactionID],
	[ProductID],
	[Quantity],
	[ActualCost],
	([Quantity] * [ActualCost]) as [TotalCost]
FROM [Production].[TransactionHistory]
WHERE [TotalCost] >= 1000;


-- can I reference TotalCost in the ORDER BY clause?  Why?

SELECT [TransactionID],
	[ProductID],
	[Quantity],
	[ActualCost],
	([Quantity] * [ActualCost]) as [TotalCost]
FROM [Production].[TransactionHistory]
ORDER BY [TotalCost];




/************************************   PART 2    ********************************************/


/* SUBQUERIES AND JOINS  
	When you need to relate tables together using common data element(s) to obtain information from both */

-- Take a look at the HumanResources.Employee table and the Person.Email address table
-- finding all the email addresses for your employees.  

Select a.EmailAddress from Person.EmailAddress  a
Where a.BusinessEntityID IN
		(SELECT e.BusinessEntityID from HumanResources.Employee e);


-- Rewritten as a join
	Select a.EmailAddress from Person.EmailAddress  a
		INNER JOIN HumanResources.Employee e on a.BusinessEntityID = e.BusinessEntityID

/* INNER JOIN -- returns rows that appear in both data sources 
example below returns 121317 rows, excludes any products that don't have any sales because that product id doesn't appear in both tables.
*/
SELECT	p.Name, 
		od.ProductID, 
		od.SalesOrderDetailID,
		od.OrderQty
FROM	[Production].[Product] as p
INNER JOIN [Sales].[SalesOrderDetail] as od
	ON p.ProductID = od.ProductID
ORDER BY p.Name, od.SalesOrderDetailID;



-- LEFT OUTER JOIN  (all rows from left table that match the right and also rows from left table that do NOT match.  In this case, products 
--                      don't have any sales.

SELECT	p.Name, 
		od.ProductID, 
		od.SalesOrderDetailID,
		od.OrderQty
FROM	[Production].[Product] as p
LEFT OUTER JOIN [Sales].[SalesOrderDetail] as od
	ON p.ProductID = od.ProductID
-- WHERE od.ProductID is null      (add this to see all of these unsold products)
ORDER BY p.Name, od.SalesOrderDetailID;

-- RIGHT OUTER JOIN  (all rows from right table that match the left and also rows from right table that do NOT match

SELECT	p.Name, 
		od.ProductID, 
		od.SalesOrderDetailID,
		od.OrderQty
FROM	[Production].[Product] as p
RIGHT OUTER JOIN [Sales].[SalesOrderDetail] as od
	ON p.ProductID = od.ProductID
ORDER BY p.Name, od.SalesOrderDetailID;


---- SELF JOIN EXAMPLE    hierarchical data such as employee / manager relationship 

ALTER TABLE [HumanResources].[Employee]
ADD [ManagerID] int NULL;
GO

-- everyone reports to CEO (1)   CEO has no manager
UPDATE [HumanResources].[Employee]
SET [ManagerID] = 1 WHERE [BusinessEntityID] <> 1;

-- Let's make all of the Sales Representatives report to the North American Sales Manager (247)
UPDATE [HumanResources].[Employee]
SET [HumanResources].[Employee].[ManagerID] = 247 WHERE [HumanResources].[Employee].[JobTitle] = 'Sales Representative'


SELECT	e.[BusinessEntityID], e.[HireDate],
		e.[ManagerID], m.[HireDate]
FROM [HumanResources].[Employee] AS e
LEFT OUTER JOIN [HumanResources].[Employee] AS m
	ON e.[ManagerID] = m.[BusinessEntityID];


-- demo clean up - remove added column
ALTER TABLE [HumanResources].[Employee]
DROP COLUMN [ManagerID];




----    JOINING MORE THAN TWO TABLES

SELECT	p.Name AS [ProductName],
		pc.Name AS [CategoryName],
		ps.Name as [SubcategoryName]
FROM [Production].[Product] as p
INNER JOIN [Production].[ProductSubCategory] AS ps
	ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN [Production].[ProductCategory] AS pc
	ON ps.ProductCategoryID = pc.ProductCategoryID
ORDER BY [CategoryName], [SubcategoryName], [ProductName];


/* UNION operator   (First run without the ALL, then with the ALL)   */

SELECT ProductID, UnitPrice
FROM [Sales].[SalesOrderDetail]
WHERE ProductID BETWEEN 1 AND 799
UNION
SELECT ProductID, UnitPrice
FROM [Sales].[SalesOrderDetail]
WHERE ProductID BETWEEN 800 AND 1000
ORDER BY ProductID


/* INTERSECT and EXCEPT Operators       121317 rows*/

SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
OrderQty, ProductID, SpecialOfferID, unitPrice, UnitPriceDiscount,
LineTotal, rowguid, ModifiedDate
INTO [Sales].[SalesOrderDetail_A]
FROM [Sales].[SalesOrderDetail];

SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
OrderQty, ProductID, SpecialOfferID, unitPrice, UnitPriceDiscount,
LineTotal, rowguid, ModifiedDate
INTO [Sales].[SalesOrderDetail_B]
FROM [Sales].[SalesOrderDetail];

DELETE TOP (15)
FROM [Sales].[SalesOrderDetail_A];

UPDATE TOP (750) [Sales].[SalesOrderDetail_B]
SET UnitPrice = 9.9999
WHERE OrderQty = 9;


-- which rows match between the two tables?
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
OrderQty, ProductID, SpecialOfferID, unitPrice, UnitPriceDiscount,
LineTotal, rowguid, ModifiedDate
FROM [Sales].[SalesOrderDetail_A]
INTERSECT
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
OrderQty, ProductID, SpecialOfferID, unitPrice, UnitPriceDiscount,
LineTotal, rowguid, ModifiedDate
FROM [Sales].[SalesOrderDetail_B]



-- which rows are in A but not B?
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
OrderQty, ProductID, SpecialOfferID, unitPrice, UnitPriceDiscount,
LineTotal, rowguid, ModifiedDate
FROM [Sales].[SalesOrderDetail_A]
EXCEPT
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
OrderQty, ProductID, SpecialOfferID, unitPrice, UnitPriceDiscount,
LineTotal, rowguid, ModifiedDate
FROM [Sales].[SalesOrderDetail_B]

-- which rows are in B but not A?
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
OrderQty, ProductID, SpecialOfferID, unitPrice, UnitPriceDiscount,
LineTotal, rowguid, ModifiedDate
FROM [Sales].[SalesOrderDetail_B]
EXCEPT
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber,
OrderQty, ProductID, SpecialOfferID, unitPrice, UnitPriceDiscount,
LineTotal, rowguid, ModifiedDate
FROM [Sales].[SalesOrderDetail_A]


-- the 750 rows that were modified and also 15 rows that were deleted.

DROP TABLE [Sales].[SalesOrderDetail_A];
DROP TABLE [Sales].[SalesOrderDetail_B];


/*  CROSS APPLY
*/
--  Table-valued function returns first name, last name, job title and business entity type for the specified contact.
--  First look at function ufnGetContactInformation

-- this one will just give you the one row (person #3)
SELECT c.BusinessEntityType, c.FirstName, c.LastName, c.JobTitle, c.PersonID 
FROM [dbo].[ufnGetContactInformation] (3) as c;

-- What if you want the metadata for people whose last names start with A?
-- Maybe you can join the person table to the TVF??

SELECT c.[BusinessEntityType], c.[FirstName], c.[LastName], c.[JobTitle]
FROM [Person].[Person] as p
INNER JOIN [dbo].[ufnGetContactInformation] (p.BusinessEntityID) as c
WHERE p.[LastName] like 'A%';

-- Now try CROSS APPLY
SELECT c.[BusinessEntityType], c.[FirstName], c.[LastName], c.[JobTitle]
FROM [Person].[Person] as p
CROSS APPLY [dbo].[ufnGetContactInformation] (p.BusinessEntityID) as c
WHERE p.[LastName] like 'A%';


/* COMMON TABLE EXPRESSION
*/

-- Define the CTE expression name and column list
WITH Sales_CTE (SalesPersonID, SalesOrderID, SalesYear)  
AS  
-- Define the CTE query.  
(  
    SELECT SalesPersonID, SalesOrderID, YEAR(OrderDate) AS SalesYear  
    FROM Sales.SalesOrderHeader  
    WHERE SalesPersonID IS NOT NULL  
)  
-- Define the outer query referencing the CTE name.  
SELECT SalesPersonID, COUNT(SalesOrderID) AS TotalSales, SalesYear  
FROM Sales_CTE  
GROUP BY SalesYear, SalesPersonID  
ORDER BY SalesPersonID, SalesYear;  
GO



/************************************   PART 3    ********************************************/



/* DEMONSTRATING AGGREGATE FUNCTIONS  */

USE AdventureWorks10;

-- Aggregate Function examples

-- AVG quantity across location/shelf/bin
SELECT	p.Name as ProductName, 
		AVG(pin.Quantity) AS AvgQuantity
FROM	[Production].[Product] as p
INNER JOIN [Production].[ProductInventory] as pin
	ON p.ProductID = pin.ProductID
GROUP BY p.Name
ORDER BY p.Name;

-- COUNT 
SELECT COUNT(*) as RowCnt
FROM [Production].[Product] as p;

--DISTINCT   (treats NULL as a distinct value as well)
SELECT DISTINCT Color
FROM [Production].[Product] as p;

-- Notice the count doesn't include NULL value
SELECT COUNT(DISTINCT Color)
FROM [Production].[Product] as p;

-- show how many places productid 1 is displayed
SELECT * from Production.ProductInventory where ProductID = 1

-- now show the number of places ALL the products are displayed using the COUNT aggregate function with GROUP BY
SELECT p.Name as ProductName,
	COUNT(pin.Shelf) as ShelfCount
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductInventory] as pin
   ON p.ProductID = pin.ProductID
GROUP By p.Name
ORDER By p.Name;


-- MIN and MAX
SELECT p.Name as ProductName,
   MIN(pin.Quantity) as MinQty,
   MAX(pin.Quantity) as MaxQty
FROM [Production].[Product] AS p
INNER JOIN [Production].[ProductInventory] AS pin
	ON p.ProductID = pin.ProductID
GROUP BY p.Name
ORDER BY p.Name;


-- Mathematical Functions

-- ceiling example
SELECT plph.ProductID,
	plph.StartDate,
	plph.ListPrice,
	CEILING(plph.ListPrice) as TaxableListPrice
FROM [Production].[ProductListPriceHistory] as plph;


-- floor example
SELECT plph.ProductID,
	plph.StartDate,
	plph.ListPrice,
	FLOOR(plph.ListPrice) as MinTaxableListPrice
FROM [Production].[ProductListPriceHistory] as plph;

-- round example
SELECT plph.ProductID,
	plph.StartDate,
	plph.ListPrice,
	ROUND(plph.ListPrice, 1) as Round1,
	ROUND(plph.ListPrice, 2) as Round2,
	ROUND(plph.ListPrice, 3) as Round3,
	ROUND(plph.ListPrice, -1) as RoundNeg1 
FROM [Production].[ProductListPriceHistory] as plph;

-- Ranking Functions

--ROW_NUMBER is often useful

SELECT p.ProductID,
	p.Name,
	ROW_NUMBER() OVER (ORDER By p.productID) as RowNum
FROM [Production].[Product] AS p
ORDER BY p.ProductID;

-- now include partition by color
SELECT p.Color,
	p.Name,
	ROW_NUMBER() OVER (PARTITION BY p.Color ORDER By p.Name) as RowNum
FROM [Production].[Product] AS p
WHERE p.Color IS NOT NULL
ORDER BY p.Color, p.Name;



-- CONVERSION FUNCTIONS

SELECT PARSE('12/31/2018' AS date) as YearEndDateUS;
SELECT PARSE('31/12/2018' AS date USING 'en-US') as YearEndDate;
SELECT PARSE('31/12/2018' AS date USING 'en-GB') as YearEndDate;

SELECT TRY_PARSE('31/12/2018' AS date USING 'en-US') as YearEndDate;

SELECT CONVERT (date, '12/31/2018', 101) AS YearEndDateUS

-- date part examples
SELECT pch.ProductID,
	pch.StartDate,
	MONTH(pch.StartDate) as StartMonth,
	DAY(pch.StartDate) as StartDay,
	YEAR(pch.StartDate) as StartYear,
	DATENAME(m, StartDate) as StartMonthName,
	DATENAME(w, StartDate) as StartWeekDayName,
	DATEPART(q, pch.StartDate) as StartQuarter
FROM [Production].[ProductCostHistory] as pch
WHERE pch.EndDate IS NOT NULL;

-- elapsed time function examples
SELECT DATEDIFF (yy, '1/1/2010', '1/1/2018') as 'YearDiff',
	DATEDIFF (mm, '1/1/2010', '1/1/2018') as 'MonthDiff',
	DATEDIFF (dd, '1/1/2010', '1/1/2018') as 'DayDiff',
	DATEDIFF (hh, '1/1/2010', '1/1/2018') as 'HourDiff',
	DATEDIFF (mi, '1/1/2010', '1/1/2018') as 'MinuteDiff',
	DATEDIFF (ss, '1/1/2010', '1/1/2018') as 'SecondsDiff'

SELECT DATEADD(dd, 30, GETDATE()) as OneMonthAfterToday,
	EOMONTH(GETDATE()) as EndOfCurrentMonth


/* STRING FUNCTIONS

	examples:  LEFT, RIGHT, LEN, LOWER, UPPER, PATINDEX, REPLACE, SUBSTRING, STUFF, RTRIM   */

	SELECT p.Name, LEFT(p.Name, 3) as Left3Chars, RIGHT(p.Name, 3) as Right3Chars, LEN(p.Name) as LengthOfName, LOWER(p.Name), UPPER(p.Name)
	FROM [Production].[Product] as p

	SELECT pd.ProductDescriptionID, pd.Description, REPLACE(pd.Description, 'alloy', 'mixture') as ModifiedDescription
	FROM [Production].[ProductDescription] as pd
	--WHERE PATINDEX('%alloy%', pd.[Description]) >0
	WHERE pd.Description like '%alloy%';

-- SUBSTRING (character expression, position, length)
	SELECT p.Name, p.ProductNumber, SUBSTRING(p.ProductNumber, 4, 3) as Chars456
	FROM [Production].[Product] as p






