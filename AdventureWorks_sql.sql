# 1 Add_SalesAmount
Use Cycling;
UPDATE Sales
SET SalesAmount = (UnitPrice * OrderQuantity) - DiscountAmount;

show tables;
select SalesAmount
from sales limit 10;

# 2 Total Revenue Per Year
select year(OrderDate) as SalesYear,
sum(SalesAmount) As Total_Revenue_PerYear
from sales
group by SalesYear
Order By SalesYear;

# 3 Top 10 products by Sales quantity

select sum(OrderQuantity) as TotalQuantity , ProductKey
from sales
group by ProductKey
order by TotalQuantity desc
limit 10;

# 4 Monthly Revenue Trend For Last Two Years

SELECT 
  DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
  SUM(SalesAmount) AS MonthlyRevenue
FROM Sales
WHERE OrderDate BETWEEN '2013-01-01' AND '2014-12-31'
GROUP BY Month
ORDER BY Month;

# 5 Average Disount given by region

select d.SalesTerritoryRegion, avg(DiscountAmount) Average_Discount
from sales s 
join dimsalesterritory d
on s.SalesTerritoryKey = d.SalesTerritoryKey
group by d.SalesTerritoryKey
order by Average_Discount desc;

# 6 Products with highest profit margin

SELECT 
  ProductKey,
  EnglishProductName,
  round((UnitPrice - StandardCost) / UnitPrice, 4) AS ProfitMargin
FROM DimProduct
WHERE UnitPrice > 0 AND StandardCost IS NOT NULL
ORDER BY ProfitMargin DESC
LIMIT 10;

# Top Ten Customers by total spend along with their Phone numbers

SELECT c.CustomerKey,
  CONCAT_WS(' ', c.FirstName, NULLIF(c.MiddleName, ''), c.LastName) AS FullName, Phone,
  sum(SalesAmount) as Total_Spend
from sales s
join dimcustomer c
on s.CustomerKey = c.CustomerKey
group by c.CustomerKey, FullName, Phone
order by Total_Spend desc
limit 10;

# 8 Customer's Average Yearly Income vs Number of Cars Owned

select CONCAT_WS(' ', FirstName, NULLIF(MiddleName, ''),LastName) AS FullName,
 YearlyIncome, NumberCarsOwned
from dimcustomer
order by NumberCarsOwned desc;

#9 Products That were never sold

select p.ProductKey, p.EnglishProductName, 0 as NumOfItemsSold
from dimproduct p 
left join sales s 
on p.ProductKey = s.ProductKey
where s.ProductKey is null;

# 10 List of Unit price > Average Unit Price

Select ProductKey, EnglishProductName, round(UnitPrice, 2) as UnitPrice,
round((select avg(UnitPrice) from dimproduct),2) as AvgUnitPrice,
round(UnitPrice - (select avg(UnitPrice) from dimproduct), 2)  as AboveAvgBy
from dimproduct
where UnitPrice > ( select avg(UnitPrice)
from dimproduct);
# 11 Average Shipping Time per Territory

select d.SalesTerritoryRegion, round(avg(datediff(s.ShipDate, s.OrderDate)), 2) as AverageShippingTime
from sales s
join dimsalesterritory d
on s.SalesTerritoryKey = d.SalesTerritoryKey
group by d.SalesTerritoryRegion
order by AverageShippingTime;

# 12 Time Taken Between First & Last Purchase

select  CONCAT_WS(' ', c.FirstName, NULLIF(c.MiddleName, ''), c.LastName) AS FullName,
c.DateFirstPurchase, max(s.OrderDate) as LastPurchase, datediff(max(s.OrderDate ), c.DateFirstPurchase)
as DaysTaken
from sales s
join dimcustomer c
on s.CustomerKey = c.CustomerKey
where c.DateFirstPurchase is not null
group by c.CustomerKey , FullName, c.DateFirstPurchase;

# 13 Inactive Customers

SELECT 
  c.CustomerKey,
  CONCAT_WS(' ', c.FirstName, NULLIF(c.MiddleName, ''), c.LastName) AS FullName,
  COUNT(s.SalesOrderNumber) AS PurchaseCount
FROM DimCustomer c
LEFT JOIN Sales s ON c.CustomerKey = s.CustomerKey
GROUP BY c.CustomerKey, FullName
HAVING PurchaseCount = 1;
