# Possible Real-world Business Questions (Answerable by SQL)
"I know how to write SQL queries, but I do not know what business questions to answer...". Here are some relevant questions to ask as a start for aspiring analysts, commercial focus. Credit: I selected from the book 'Real SQL Queries, 50 challenges'

## Calculate revenue by regions
Goal: to identify top performers
| State | Revenue | 
| -------- | -------- | 
| California  | 1000000  | 

## Calculate number of orders within revenue ranges
Goal: to compare the distribution of order values   
| Sort ID | Sales Category | Orders # |
| -------- | -------- | -------- |
| 1  | $0-$100  | 10 |
| 2  | $100 - $500  | 10 |
| 3  | $500 - $1000  | 10 |
| 4  | > $1000  | 10 |

## Calculate profit margins for specific products
Goal: to compare product profitability. Formula: Profit Margin = % Diff of Price and Cost
| Product ID | Product Name | Profit Margin |
| -------- | -------- | -------- |
| 1  | Bike  | 10 | 0.45 |

## Determine if products were overpaid
Context: some products could be purchased from multiple vendors. The goal is to compare the prices between vendors.
| Product ID | Most Expensive Price | 2nd Most Expensive Price | % Price diff |
| -------- | -------- | -------- | -------- |
| 1  | Bike  | 30 | 27 | 0.1 |

## Calculate volume discounts
Goal: to compare volume discounts. Define: volume discounts is total discounts applied to an order
| SalesOrderID | OrderDate | DiscountVolume |
| -------- | -------- | -------- |
| 1  | Bike  | 10 | 0.45 |

## Forecast revenue for the rest of the month
Goal: to forecast the revenue of remaining days, and compare with actual revenue
Formula: moving average technique
| Day in Month | Current Revenue | Forecast Revenue | Actual Revenue | Variance |
| -------- | -------- | -------- | -------- | -------- |
| 1  | 280 | 0 | 280 |0|
| 2 | 300 | 0 | 300 |0|
| 3 | 270 | 0 | 270 |0|
| 4 | 0 | 283 | 260 |0.09|

## Calculate variability in product costs
Formula: Historical	cost	variability =	maximum	historical	cost	-	minimum historical	cost. Ranking =	“1”	reflects	the	product	ID	exhibiting	the	greatest	historical	cost	variability
| ProductID | ProductName | SubCategory | Minimum	historical	cost|Maximum	historical	cost|Historical	cost	variability|Ranking|		
| -------- | -------- | -------- | -------- | -------- |-------- |-------- |
| 1 | Nice Bike | Bikes | 22 |30|+0.4|1|	

## Long time no sale
Goal: identify stores whose last order date was 12 months ago
|Store|Last Order Date|No of Months Since Last Order|
|----|----|----|
|1|2025-07-01|13|

## Other business questions
- Compare the sales of 2008's quarters vs 2007's quarters
- Test the effect of promotions
- Find the first dates of year that sales reach the benchmark
- Calculate revenue per week of day to test the week of day's promotions
- Calculate % of orders containing at least 2 items to find the upsell opportunities
- Compare median and mean revenue to detect outliers
