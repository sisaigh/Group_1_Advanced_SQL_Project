--Projects 3 and 4: SQL and Power BI 
--Use Microsoft's AdventureWorks sample database for these projects
--Part 1: SQL Related Questions: DUE SATURDAY, APRIL 6
--1. Sales Performance Analysis:
	--1.1. Generate a report showcasing the total sales amount for each product category 
	--over the past three years. 
	     --Include a trend analysis to identify any significant changes in sales volume.
		 		 		 			  

	--1.2. Write SQL queries to retrieve sales data from the AdventureWorks database, 
	     --grouping by product category and aggregating sales amounts over time.

		 --Creating view for all sales 
		 Create view  All_Sales AS
		 Select ProductKey, 
				OrderDateKey, 
				DueDateKey, 
				ShipDateKey, 
				CustomerKey,
				PromotionKey, 
				CurrencyKey, 
				SalesTerritoryKey, 
				SalesOrderNumber, SalesOrderLineNumber,
				RevisionNumber, OrderQuantity, UnitPrice, 
				ExtendedAmount, UnitPriceDiscountPct, DiscountAmount,
				ProductStandardCost, TotalProductCost, SalesAmount, TaxAmt, 
				Freight, CarrierTrackingNumber, CustomerPONumber, OrderDate, DueDate,
				ShipDate
		 from [dbo].[FactInternetSales]
		 Union 
		 Select ProductKey, OrderDateKey, DueDateKey, ShipDateKey, 
				ResellerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, 
				SalesOrderNumber, SalesOrderLineNumber, RevisionNumber, OrderQuantity, 
				UnitPrice, ExtendedAmount, UnitPriceDiscountPct, DiscountAmount, 
				ProductStandardCost, TotalProductCost, SalesAmount, TaxAmt, Freight, 
				CarrierTrackingNumber, CustomerPONumber, OrderDate, DueDate, ShipDate
		 from [dbo].[FactResellerSales];

	--creating view for all products 

		Create View All_Product_Sales AS
		Select PC.EnglishProductCategoryName,
		PSC.EnglishProductSubcategoryName,
		P.EnglishProductName,Als.OrderDate,
		Year(Als.OrderDate) as Order_Year, 
		Month(Als.OrderDate) as Order_Month, 
		Als.SalesAmount 
		 from
		 	[dbo].[DimProductCategory] PC 
			Inner Join [dbo].[DimProductSubcategory] PSC on pc.ProductCategoryKey = PSC.ProductCategoryKey
			Inner Join [dbo].[DimProduct] P on PSC.ProductSubcategoryKey = P.ProductSubcategoryKey
			Inner Join All_Sales als on als.ProductKey= P.ProductKey

Create View All_Product_Sales_2 AS
		Select PC.EnglishProductCategoryName,
		PSC.EnglishProductSubcategoryName,
		P.EnglishProductName,Als.OrderDate,
		Year(Als.OrderDate) as Order_Year, 
		Month(Als.OrderDate) as Order_Month, 
		Als.SalesAmount 
		 from
		 	[dbo].[DimProductCategory] PC 
			Inner Join [dbo].[DimProductSubcategory] PSC on pc.ProductCategoryKey = PSC.ProductCategoryKey
			Inner Join [dbo].[DimProduct] P on PSC.ProductSubcategoryKey = P.ProductSubcategoryKey
			Inner Join All_Sales als on als.ProductKey= P.ProductKey
			Where DATEDIFF(year,OrderDate,'2014-01-28') <=3 

--drop view All_Product_Sales

--- Sales in the last three years considering from 2014

Select APS.EnglishProductCategoryName, 
     Order_Year,
	 Sum(APS.SalesAmount) total_sales 
From All_Product_Sales_2 APS
Group by APS.EnglishProductCategoryName, Order_Year
Order by APS.EnglishProductCategoryName, Order_Year


--Trend Analysis 

Select sub2.*, sub2.total_sales-sub2.Lagged_monthly_salesamount change_daily_amount,
(sub2.total_sales-sub2.Lagged_monthly_salesamount)*100/sub2.Lagged_monthly_salesamount percetage_change
FROM
(SELECT sub.*,
LAG(sub.total_sales) OVER (Partition by sub.EnglishProductCategoryName ORDER BY sub.EnglishProductCategoryName,sub. order_year,sub.Order_Month) Lagged_monthly_salesamount
From
(Select APS.EnglishProductCategoryName,
     order_year,Order_Month,
     Sum(APS.SalesAmount) total_sales 
From All_Product_Sales_2 APS
Group by APS.EnglishProductCategoryName,order_year,Order_Month
) sub)sub2


--2. Customer Segmentation:
	--2.1. Segment customers based on their purchase behavior and demographics. 
		 --Use SQL to extract relevant customer data such as age, gender, purchase frequency, and total spend.
	--2.2. Write SQL queries to join customer data tables and calculate metrics 
		 --like purchase frequency and total spend for each customer.

		SELECT fis.customerkey,
			CONCAT(FirstName, ' ', LastName) AS FullName,
			BirthDate,
			Gender,
			DATEDIFF(year, BirthDate, '2014-01-28') AS Age, 
			count(FIS.CustomerKey) as Frequency,
			SUM(SalesAmount) AS TotalSales
			FROM 
			[dbo].[DimCustomer] AS C
		INNER JOIN 
			 [dbo].[FactInternetSales] AS FIS ON C.CustomerKey = FIS.CustomerKey
		GROUP BY 
			 FIS.CustomerKey,FirstName, LastName, BirthDate, Gender

-- by creating view 

	Create View customer_total_sale as 
		SELECT 
			CustomerKey,count(SalesAmount) freqency,
			SUM(SalesAmount) AS TotalSales
			FROM 
			 [dbo].[FactInternetSales] 
GROUP BY  
    customerkey 
 
 -- Inner joined with the view 
 	SELECT fis.customerkey,
			CONCAT(FirstName, ' ', LastName) AS FullName,
			BirthDate,
			Gender,
			DATEDIFF(year, BirthDate, '2014-01-28') AS Age, freqency,TotalSales
			FROM 
			[dbo].[DimCustomer] AS C
		INNER JOIN 
			customer_total_sale AS FIS ON C.CustomerKey = FIS.CustomerKey
			
			
-- 1) Gender - M, F 
--  Age 25-50, 51-75, 76-100
--  Frequecy - 1-20, 21-40, 41-60,61-80
-- Total Spend - 1-3000, 3001-6000,6001-9000,9001-12000, 12001-15000


		Select sub1.* from 
		(SELECT fis.customerkey,
			CONCAT(FirstName, ' ', LastName) AS FullName,
			BirthDate,
			Gender,
			DATEDIFF(year, BirthDate, '2014-01-28') AS Age, freqency,TotalSales
			FROM 
			[dbo].[DimCustomer] AS C
		INNER JOIN 
			customer_total_sale AS FIS ON C.CustomerKey = FIS.CustomerKey) sub1
			WHERE Age between 25 and 50 and Gender = 'F' and freqency between 21 and 40 and TotalSales <=3000
			Order by Age

		
-- by Location country code 

		Select sub1.* from 
		(SELECT fis.customerkey,
			CONCAT(FirstName, ' ', LastName) AS FullName,
			BirthDate,
			Gender,
			DATEDIFF(year, BirthDate, '2014-01-28') AS Age, freqency,TotalSales,CountryRegionCode
			FROM 
			[dbo].[DimCustomer] AS C
		INNER JOIN 
			customer_total_sale AS FIS ON C.CustomerKey = FIS.CustomerKey
		Inner JOIN  [dbo].[DimGeography] G ON G.GeographyKey = C.GeographyKey) sub1
			WHERE Age between 25 and 50 and Gender = 'M' and freqency between 1 and 20 and (CountryRegionCode = 'AU' or CountryRegionCode = 'CA')
			Order by Age


Select * 
from INFORMATION_SCHEMA.COLUMNS
where COLUMN_NAME  like '%marketing%'
order by Table_name


--3. Inventory Management:
	--3.1. Analyze the inventory turnover rate for each product. 
		 --Calculate the ratio of cost of goods sold to average inventory value for the past year.
	--3.2. Write SQL queries to calculate inventory turnover metrics using data on sales, purchases, 
		 --and inventory levels from the AdventureWorks database.
		 
		Select	sub.productkey,sum(sub.TotalProductCost) [Total Product Cost], 
				AVG(sub.UnitCost*sub.UnitsBalance) [Average Inventory Value]
		from 
				(Select als.ProductKey,als.TotalProductCost,als.SalesAmount,PRI.UnitCost,PRI.UnitsBalance
				 From [dbo].[FactProductInventory] PRI
					Inner Join All_Sales als on als.ProductKey=PRI.ProductKey) sub
		Group by sub.ProductKey
		Order by Sub.ProductKey



Select*
From [dbo].[FactProductInventory] PRI
where ProductKey =212
order by DateKey

Select*
From [dbo].[FactInternetSales]
Order by ProductKey

Select sum (totalproductcost) [Total Prodcut Cost]
From
[dbo].[FactResellerSales]
where ProductKey =212

		 Select*
		 From All_Sales
			where ProductKey =212


--4. Employee Performance Evaluation:
	--4.1. Evaluate the performance of sales employees by analyzing their sales activities. 
		 --Calculate metrics such as total sales amount, number of deals closed, and average deal size for each employee.
	--4.2. Write SQL queries to aggregate sales data by employee, 
		 --calculating performance metrics based on sales transactions.

		 select sub2.* , 
		 RANK() over(order by sub2.[average deal size] desc) [Ranking]
		 from 
(		select sub.EmployeeKey, sub.[Full Name], 
			SUM(sub.SalesAmount)  [Total sales],
			COUNT(sub.SalesOrderNumber) [Total Deal closed],
			SUM(sub.SalesAmount)/COUNT(sub.SalesOrderNumber) [average deal size]

		from (
		Select em.EmployeeKey, CONCAT(FirstName, ' ' , LastName) [Full Name] 
		, SalesAmount, SalesOrderNumber
		 From [dbo].[DimEmployee] em
          inner join [dbo].[FactResellerSales] fc
		  on fc.EmployeeKey= em.EmployeeKey)sub
        group by EmployeeKey, [Full Name]) sub2

		

	

--5. Supplier Analysis:
	--5.1. Assess the performance of suppliers based on their delivery times and product quality. 
		 --Extract data on lead times, on-time delivery rates, and return rates from the database.
	--5.2. Write SQL queries to retrieve supplier performance metrics from tables containing information on 
		 --purchases, deliveries, and returns.




--6. Product Profitability Analysis:
	--6.1. Calculate the profitability of each product by subtracting the cost of goods sold from 
		 --the total revenue generated. Consider factors such as discounts and returns in your calculations.
	--6.2. Write SQL queries to calculate product profitability metrics using data on 
		 --sales, costs, and discounts from the AdventureWorks database.


		 
Select	sub.productkey,sum(ExtendedAmount) [Total Extended Sales], 
		sum(sub.TotalProductCost) [Total Product Cost], 
		Sum(DiscountAmount) [Total Discount],
		sum(ExtendedAmount)-sum(sub.TotalProductCost)-Sum(DiscountAmount) as [Total Profit],
		(sum(ExtendedAmount)-sum(sub.TotalProductCost)-Sum(DiscountAmount))/sum(ExtendedAmount) as [Profit Margin]
		from 
			(Select als.ProductKey,
			als.TotalProductCost,
			als.ExtendedAmount,
			als.DiscountAmount
			From [dbo].[FactProductInventory] PRI
				Inner Join All_Sales als
				on als.ProductKey=PRI.ProductKey) sub
		Group by sub.ProductKey
		Order by Sub.ProductKey


--7. Marketing Campaign Effectiveness:
	--7.1. Measure the effectiveness of marketing campaigns by analyzing sales data before and after the campaigns. 
		 --Calculate metrics such as sales lift, ROI, and customer acquisition cost.
	--7.2. Write SQL queries to extract sales data before and after specific marketing campaigns, 
		 --calculating performance metrics based on campaign periods and customer behavior.

select *
from [dbo].[DimPromotion]

select *
from [dbo].[FactInternetSales]
order by PromotionKey DESC

--Total sales revenue generated by the promotion

--Number of orders placed using the promotion

--Number of unique customers who used the promotion

--Average order value for orders using the promotion

--8. Customer Retention Analysis:
	--8.1. Analyze customer retention rates by calculating the percentage of 
		 --customers who make repeat purchases within a specified time period. 
		 --Use SQL to extract data on customer transactions and dates.
	--8.2. Write SQL queries to identify repeat customers and calculate retention rates 
		 --based on their purchase history and transaction dates.

		
		 Select SUB.customerkey, SUB.CustomerName,count (sub.salesordernumber) Totalorder
		 From 
		 (Select c.CustomerKey, CONCAT(FirstName,' ',LastName) CustomerName,
		        als.ProductKey,
				als.SalesOrderNumber,
				als.OrderDate,Year(OrderDate) OrderYear 
		 from All_Sales als
		 Inner Join [dbo].[DimCustomer] C on c.CustomerKey=als.CustomerKey) SUB
		 Where sub.Orderdate between '2010-01-01' and '2014-12-31'
		 Group by Sub.CustomerKey,sub.CustomerName
		 order by Totalorder DESC
		 


--9. Supply Chain Optimization:
	--9.1. Optimize the supply chain by analyzing the time it takes for products to move from suppliers to customers. 
		 --Calculate lead times, transit times, and delivery performance metrics.
	--9.2. Write SQL queries to retrieve data on supply chain activities such as orders, 
		 --shipments, and deliveries, calculating performance metrics related to lead times and delivery times.

--10. Forecasting and Demand Planning:
	--10.1. Use historical sales data to forecast future demand for products. 
		  --Apply time series forecasting techniques such as ARIMA or exponential smoothing to predict sales trends.
	--10.2. Prepare SQL queries to extract historical sales data and aggregate it into 
		  --suitable formats for forecasting models. 
		  --Optionally, students can also implement basic forecasting algorithms directly in SQL.



--	Part 2: Power BI Related Questions: Due Saturday, April 20
--1. Sales Performance Analysis:
	--Utilize Power BI to create visualizations displaying total sales amount trends for each product category over time. 
	--Implement filters to allow users to drill down into specific time periods or products.
--2. Customer Segmentation:
	--Create Power BI visualizations depicting customer segments based on purchase behavior and demographics. 
	--Compare metrics such as average purchase amount and frequency across different segments.
--3. Inventory Management:
	--Develop Power BI dashboards illustrating inventory turnover metrics by product category. 
	--Identify slow-moving inventory items and visualize their impact on overall profitability.
--4. Employee Performance Evaluation:
	--Build Power BI dashboards featuring leaderboards ranking employees based on their sales performance metrics. 
	--Include filters to allow users to focus on specific time periods or regions.
--5. Supplier Analysis:
	--Visualize supplier performance metrics using Power BI, identifying any bottlenecks or issues in the supply chain. 
	--Implement interactive features to explore supplier data by region or product category.
--6. Product Profitability Analysis:
	--Create Power BI dashboards showcasing the profitability of products over time. 
	--Identify top-performing products and analyze the factors contributing to their success.
--7. Marketing Campaign Effectiveness:
	--Utilize Power BI to visualize the effectiveness of marketing campaigns, 
	--comparing sales metrics before and after each campaign. 
	--Implement filters to analyze campaign performance by channel or demographic.
--8. Customer Retention Analysis:
	--Develop Power BI visualizations tracking customer retention rates over time. 
	--Identify trends and patterns in customer behavior to inform retention strategies.
--9. Supply Chain Optimization:
	--Build Power BI dashboards illustrating supply chain performance metrics such as lead times and delivery performance. 
	--Implement filters to drill down into specific regions or products.
--10. Forecasting and Demand Planning:
	--Create interactive forecasting models in Power BI based on historical sales data. 
	--Evaluate forecast accuracy and adjust models as needed based on actual sales performance.