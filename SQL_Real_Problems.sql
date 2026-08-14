use AdventureWorks2022;

/* Challenge 1: YoY comparisons
Request: retrieve fiscal quarter sales data by salesperson.
Comparisons from fiscal quarters of 2008 to the same fiscal quarter 2007.
Fiscal year 07: 07/2007 to 06/2008
Fiscal year 08: 07/2008 to 06/2009
Do not include tax and freight
Use Orderdate
Disregard online orders

Contains:
	LastName,
	SalesPersonID,
	Fiscal year FY,
	Fiscal quarter FQ,
	Fiscal quarter sales FQSales,
	SalesSameFQLast,
	Change in revenue Change,
	% change in revenue between 2 periods %Change

*/
select year(orderdate) as FY,datepart(quarter,orderdate) as FQ , sum(subtotal) as Sales 
from sales.SalesOrderHeader
group by year(orderdate),datepart(quarter,orderdate);
select top 5 * from person.Person;

with FY2013 as (select 
	p.LastName,
	s.SalesPersonID,
	year(s.orderdate) as FY,
	datepart(quarter,s.OrderDate) as FQ,
	sum(s.subtotal) as FQSales,
	format(s.OrderDate,'yyyy-MM-dd') as NewDate
from sales.SalesOrderHeader as s
join person.Person as p
on s.SalesPersonID = p.BusinessEntityID
where format(s.OrderDate,'yyyy-MM-dd') between '2013-07-01' and '2014-30-06'
group by p.LastName,s.SalesPersonID,year(s.orderdate),
		datepart(quarter,s.OrderDate),format(s.OrderDate,'yyyy-MM-dd')),

FY2012 as (select 
	p.LastName,
	s.SalesPersonID,
	year(s.orderdate) as FY,
	datepart(quarter,s.OrderDate) as FQ,
	sum(s.subtotal) as FQSales,
	format(s.OrderDate,'yyyy-MM-dd') as NewDate
from sales.SalesOrderHeader as s
join person.Person as p
on s.SalesPersonID = p.BusinessEntityID
where format(s.OrderDate,'yyyy-MM-dd') between '2012-07-01' and '2013-30-06'
group by p.LastName,s.SalesPersonID,year(s.orderdate),
		datepart(quarter,s.OrderDate),format(s.OrderDate,'yyyy-MM-dd'))

select
	f1.LastName,
	f1.SalesPersonID,
	f1.FY,
	f1.FQ,
	sum(f1.FQSales) as FQSales,
	sum(f2.FQSales) as SalesSameFQLast,
	(sum(f2.FQSales) - sum(f1.FQSales)) as Change,
	(sum(f2.FQSales) - sum(f1.FQSales))/sum(f1.FQSales)*100 as PercChange
from FY2013 as f1
left join FY2012 as f2
on f1.SalesPersonID = f2.SalesPersonID
group by 
	f1.LastName,
	f1.SalesPersonID,
	f1.FY,
	f1.FQ
order by LastName,FY,FQ;

/* Challenge 2 - The 2/22 promotion
Create a table includes:
- SalesOrderID
- Ship to State (california)
- OrderDate
- Historical order subtotal (prior to changes from promotion)
- Historical freight (prior to changes from promotion)
- Potential Promotional Effect
- Potential Order Gain
- Potential Freight Loss
- Potential Promotional Net Gain/Loss

*/
select top 2 * from sales.SalesOrderHeader;
select top 2 * from person.BusinessEntityAddress;
select top 2 * from person.address;
select top 2 * from person.StateProvince;

with PromotionalEffect as (select
	s.SalesOrderID,
	sp.Name as ShipToState,
	try_convert(date,s.OrderDate) as NewDate,
	sum(s.subtotal) as SubTotal,
	sum(s.freight) as Freight,
	case
		when (sum(s.subtotal) between 1700 and 2000) then 'Increase order to 2000 and pay 0.22 freight'
		when (sum(s.subtotal) >= 2000) then 'Pay 0.22 freight'
		else 'No order change and pay historical freight' end as PotentialPromotionalEffect,
	case 
		when (sum(s.subtotal) between 1700 and 2000) then (2000 - (sum(s.subtotal)))
		when (sum(s.subtotal) >= 2000) then 0
		else 0 end as PotentialOrderGain,
	case
		when (sum(s.subtotal) between 1700 and 2000) then (sum(s.freight) - 0.22)
		when (sum(s.subtotal) >= 2000) then (sum(s.freight) - 0.22)
		else 0 end as PotentialFreightLoss,
	case
		when (sum(s.subtotal) between 1700 and 2000) then (2000 - sum(s.subtotal) - sum(s.freight) + 0.22)
		when (sum(s.subtotal) >= 2000) then (-sum(s.freight) + 0.22)
		else 0 end as PromotionalNetGain
from sales.SalesOrderHeader as s
left join person.Address as a on s.ShipToAddressID = a.AddressID
left join person.StateProvince as sp on a.StateProvinceID = sp.StateProvinceID
where sp.name = 'California'
group by s.SalesOrderID,
	sp.Name,
	s.OrderDate)

select 
	PotentialPromotionalEffect,
	sum(potentialordergain) as PotentialOrderGain,
	sum(potentialfreightloss) as PotentialFreightLoss,
	sum(promotionalnetgain) as PromotionalNetGain
from PromotionalEffect
group by PotentialPromotionalEffect;

/* Challenge 3 - Ten million dollar benchmark 

Ten million dollars of revenue is the benchmark for the company. 
For each year 2014 and 2013, find the dates when the cumulative running revenue total hit $10m.
Exclude tax and freight

Columns include:
- FiscalYear
- OrderDate
- FYOrder#
- RunningTotal

*/
with RunningTotal as 
(select 
	FiscalYear,
	OrderDate,
	FYOrder#,
	sum(subtotal) over (partition by fiscalyear order by orderdate) as RunningTotal
from (select
	datepart(year,OrderDate) as FiscalYear,
	try_convert(date,OrderDate) as OrderDate,
	row_number() over (partition by datepart(year,OrderDate) order by try_convert(date,OrderDate)) as FYOrder#,
	sum(subtotal) as SubTotal
from sales.SalesOrderHeader
where datepart(year,OrderDate) = 2014 or datepart(year,OrderDate) = 2013
group by datepart(year,OrderDate),try_convert(date,OrderDate)) as SubTotal
)
select top (1) with ties
	FiscalYear,
	OrderDate,
	FYOrder#,
	RunningTotal
from RunningTotal
where RunningTotal >= 10000000
order by ROW_NUMBER() over (partition by FiscalYear order by FYOrder#);

/* Challenge 4 - Upsell Tuesdays

Tuesday's upsell day for salespeople. Compare Tuesday's sales with other days. 
Calculate average revenue per order by day of the week in 2014

Columns include:
- Day of week
- Revenue
- Orders
- Revenue per order
*/

select
	datename(weekday,s.orderdate) as DayofWeek,
	sum(s.subtotal) as SubTotal,
	count(s.SalesOrderID) as Order#,
	sum(s.subtotal)/count(s.SalesOrderID) as AOV
from sales.SalesOrderHeader as s
group by datename(weekday,s.orderdate)
order by AOV desc;

/* Challenge 9 - Product combinations

Calc - % of sales orders containing at least 1 bike and at least 1 accessory item.
Calc % of sales orders containing at least 1 bike and at least 2 different clothing products.

*/
select top 1 * from sales.SalesOrderHeader;
select top 1 * from sales.SalesOrderDetail;
select top 1 * from production.product;
select distinct name from Production.ProductCategory;
select top 1 * from Production.ProductSubcategory;

select
	soh.SalesOrderID,
	pc.Name,
	sum(soh.SubTotal) as SubTotal
from sales.SalesOrderHeader as soh
left join sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
left join production.Product as p on sod.ProductID = p.ProductID
left join production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
left join production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID
where pc.Name = 'Bikes' or pc.Name = 'Accessories'
group by soh.SalesOrderID,pc.Name
order by soh.SalesOrderID;

select
from sales.sal


