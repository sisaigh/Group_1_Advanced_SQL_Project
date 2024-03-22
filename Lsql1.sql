 Generate a report showcasing the total sales amount for each product category 
	--over the past three years. 
	     --Include a trend analysis to identify any significant changes in sales volume.

		 		 			  

	--1.2. Write SQL queries to retrieve sales data from the AdventureWorks database, 
	     --grouping by product category and aggregating sales amounts over time.
 Create view  All_Sales AS
		 Select ProductKey, OrderDateKey, DueDateKey, ShipDateKey, CustomerKey,PromotionKey, CurrencyKey, SalesTerritoryKey, SalesOrderNumber, SalesOrderLineNumber, RevisionNumber, OrderQuantity, UnitPrice, ExtendedAmount, UnitPriceDiscountPct, DiscountAmount, ProductStandardCost, TotalProductCost, SalesAmount, TaxAmt, Freight, CarrierTrackingNumber, CustomerPONumber, OrderDate, DueDate, ShipDate
		 from [dbo].[FactInternetSales]
		 Union 
		 Select ProductKey, OrderDateKey, DueDateKey, ShipDateKey, ResellerKey, PromotionKey, CurrencyKey, SalesTerritoryKey, SalesOrderNumber, SalesOrderLineNumber, RevisionNumber, OrderQuantity, UnitPrice, ExtendedAmount, UnitPriceDiscountPct, DiscountAmount, ProductStandardCost, TotalProductCost, SalesAmount, TaxAmt, Freight, CarrierTrackingNumber, CustomerPONumber, OrderDate, DueDate, ShipDate
		 from [dbo].[FactResellerSales];

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
			


--- Sales in the last three years considering from 2014

Select APS.EnglishProductCategoryName, 
     order_year,
	 Sum(APS.SalesAmount) total_sales 
From All_Product_Sales APS
Group by APS.EnglishProductCategoryName,order_year
HAVING DATEDIFF(year,order_year,'2014-12-31') > 3 
Order by APS.EnglishProductCategoryName,order_year


--Trend Analysis 
Select sub2.*, sub2.total_sales-sub2.Lagged_monthly_salesamount change_daily_amount,
 (sub2.total_sales-sub2.Lagged_monthly_salesamount)*100/sub2.Lagged_monthly_salesamount percetage_change
 FROM
(SELECT sub.*,
LAG(sub.total_sales) OVER (ORDER BY sub.EnglishProductCategoryName,sub. order_year,sub.Order_Month) Lagged_monthly_salesamount 
From 
(Select APS.EnglishProductCategoryName, 
     order_year,Order_Month,
	 Sum(APS.SalesAmount) total_sales 
From All_Product_Sales APS
Group by APS.EnglishProductCategoryName,order_year,Order_Month
) sub)sub2
