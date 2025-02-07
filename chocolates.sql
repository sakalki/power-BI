-- Awesome Chocolates DB
show tables;

-- Sales Table
desc sales;

select * from sales;

select SaleDate, Amount, Customers from sales;

select SaleDate, Amount, Boxes, Amount/Boxes as 'Cost Per Box' from sales;

select * from sales
where Amount>10000;

select * from sales
where Amount>10000
order by Amount;

select * from sales
where Amount>10000
order by Amount desc;

select * from sales
where GeoID='G1'
order by PID, Amount desc;

select * from sales
where amount>10000 and SaleDate>='2022-01-01';

select * from sales
where Amount > 10000 and year(SaleDate)=2022
order by Amount desc;

select * from sales
where Boxes between 1 and 50
order by Boxes;

select SaleDate, Amount, weekday(SaleDate) as'Day of Week' from sales
where  weekday(SaleDate) =4;

-- People Table
select * from people;

select count(*) from people;

select * from people
where team ='Delish' or team='Juices' or team= 'Yummies';
-- or--  
select * from people
where team in('Delish', 'Juices','Yummies');

select * from people
where Salesperson like 'B%';

select * from people
where upper(Salesperson) like'%B%';

desc people;

-- Split Fullname
ALTER TABLE people
ADD COLUMN fname VARCHAR(255) GENERATED ALWAYS AS (SUBSTRING_INDEX(Salesperson, ' ', 1)) STORED,
ADD COLUMN lname VARCHAR(255) GENERATED ALWAYS AS (SUBSTRING_INDEX(Salesperson, ' ', -1)) STORED;

-- Rename column name
ALTER TABLE people
	RENAME COLUMN fname TO FirstName,
	RENAME COLUMN lname TO Surname;

-- Reordering Columns 
ALTER TABLE people
  MODIFY FirstName VARCHAR(255) NOT NULL AFTER Salesperson;
  
  ALTER TABLE people
  MODIFY Surname VARCHAR(255) NOT NULL AFTER FirstName;
  
--   Drop Duplicate Columns
ALTER TABLE people
    DROP COLUMN fname,
    DROP COLUMN lname;

-- Case Operator  
select  SaleDate, Amount,
		case 
			when Amount < '10000' then 'under 10000'
			when Amount >='10000' and Amount <'20000' then 'under 20000'
            when Amount >='30000' and Amount < '40000' then 'under 30000'
		else 'greater than 30000' 
        end as 'Amount Insights'
from sales
LIMIT 5;

-- JOINS 
select * from sales;
select * from geo;
select * from products;
select * from people;

-- Join or Inner join looks for common rows matching the condition from both tables
select p.Salesperson, p.spid, s.SaleDate, s.Amount
from sales s
join people p on s.spid=p.spid;

-- Left join is predominently used
-- Left join lists all rows in left table along with matching data in right table

select pr.PID, s.amount,  pr.product
from sales s
left join products pr on s.PID = pr.PID;

select p.Salesperson, p.spid, s.SaleDate, s.Amount, pr.Product, pr.PID
from sales s
join people p on s.spid=p.spid
join products pr on s.PID = pr.PID;

-- Conditional & multiple Joins
select p.Salesperson, p.spid, s.SaleDate, s.Amount, pr.Product, pr.PID, p.team, g.Geo
from sales s
join people p on s.spid=p.spid
join products pr on s.PID = pr.PID
join geo g on s.GeoID = g.GeoID
where s.Amount <= 5000
and p.Team in ('', 'Delish') -- these fields are not set to null but as an empty string.
and g.Geo = 'India'; 

-- GroupBy, Having & Aggregate functions
-- GROUP BY is used to group rows that share the same value(s) in specified columns, so you can apply aggregate functions (like SUM, COUNT, AVG) on each group rather than on the entire dataset.
-- Rules: All columns in the SELECT list (other than those wrapped in an aggregate function) must appear in the GROUP BY
-- 'Having' is similar to 'where' clause but 'Having' is applied only to apply conditions on the grouped data i.e., aggregate function. So it is always preceeded by 'GROUP BY'

select GeoID, sum(Amount) as 'total amount'
from sales
group by GeoID
having sum(Amount)> '7200000';

-- Add joins on Group BY
select s.GeoID, sum(s.Amount) as 'total amount', g.Geo
from sales s
join geo g on g.GeoID =s.GeoID
group by g.GeoID
having sum(s.Amount)> '7200000';

select pr.category, p.team, sum(s.boxes), avg(s.amount)
from sales s
join products pr on s.pid=pr.pid
join people p on s.spid=p.spid
where p.team <> ''
group by pr.category, p.team
having avg(s.amount) between '5500' and '6000';

-- List top 10 products based on the amount of sales
select pr.Product, sum(s.amount) as 'total amount'
from sales s
join products pr on s.pid=pr.pid
group by pr.Product
order by sum(s.amount) desc 
limit 10;                




-- Questions:
-- 1. Print details of shipments (sales) where amounts are > 2,000 and boxes are <100?
select pr.product, s.amount, s.boxes
from sales s
join Products pr on s.pid=pr.pid
where s.amount> '2000' and s.boxes <'100';

-- 2. How many shipments (sales) each of the sales persons had in the month of January 2022?
select p.salesperson,  s.saledate as 'January Month Sales', count(*) as 'Number of shipments'
from sales s
join people p on s.spid=p.spid
where s.SaleDate between '2022-01-01' and '2022-01-31'
group by p.salesperson, s.saledate;

-- 3. Which product sells more boxes? Milk Bars or Eclairs?
-- Answer: MilkBars: 352, Eclairs: 346
select * from products;
select * from sales;

select pr.product, count(*)
from sales s
join Products pr on s.pid=pr.pid
where pr.product = 'Milk Bars' or pr.product ='Eclairs'
group by pr.product;

-- 4. Which product sold more boxes in the first 7 days of February 2022? Milk Bars or Eclairs?
-- Answer: Eclairs

select pr.product, count(*)
from sales s
join products pr on s.pid=pr.pid
where s.saledate  between '2022-02-01' and '2022-02-07'
and pr.product = 'Milk Bars' or pr.product ='Eclairs'
group by pr.product;

-- 5. Which shipments had under 100 customers & under 100 boxes? Did any of them occur on Wednesday?
-- Answer: 

select s.*, s.saledate as 'Wednesday Shipment'
from sales s
where s.boxes <100 and s. customers<100
and weekday(s.saledate)=2;

-- 1. What are the names of salespersons who had at least one shipment (sale) in the first 7 days of January 2022?
select p.salesperson, s.saledate, count(s.boxes)
from sales s
join people p on s.spid=p.spid
where s.saledate between '2022-02-01' and '2022-02-07'
and s.Boxes>= 1
group by p.salesperson, s.saledate;

select * from sales;
select * from people;
select * from product;

-- 2. Which salespersons did not make any shipments in the first 7 days of January 2022?
select p.salesperson, count(s.boxes)
from sales s
join people p on s.spid=p.spid
where s.saledate between '2022-02-01' and '2022-02-07'
and s.Boxes< 1
group by p.salesperson;

-- 3. How many times we shipped more than 1,000 boxes in each month?

select year(saledate) as 'Year', month(saledate) as 'Month', count(*) as 'Shippment > 1000'
from sales
where boxes>1000
group by year(saledate), month(saledate)
order by year(saledate), month(saledate); 

-- 6. List the highest products sold in every year
select pr.product, year(saledate), count(*) as 'boxes sold every year'
from sales s
join products pr on s.pid=pr.pid
group by  pr.product, year(saledate); 


-- 4. Did we ship at least one box of ‘After Nines’ to ‘New Zealand’ on all the months?
-- 5. India or Australia? Who buys more chocolate boxes on a monthly basis?
-- Things to learn 
-- Power Query in Excel(used to transform data before reporting)
-- Vlookup in Excel
-- Data Modeling
-- Excel Shortcuts
-- DAX Queries
-- Calculation Groups - Mom, YoY

-- Sales per Geo

select g.geo, sum(s.amount) as 'Total Sales'
from sales s
join geo g on s.GeoID= g.GeoID
group by g.geo;