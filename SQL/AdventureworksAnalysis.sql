-- Adventure Works cycle Analysis
-- Union Factinternetsales and fact_internet_sales_new as sales
create table Sales as
select * from factinternetsales
union all 
select * from fact_internet_sales_new;
select count(*) from sales;
-- Lookup the productname from productsheet to sales sheet
describe sales;
describe dimproduct;
alter table sales add column product_name varchar(50);
update sales s inner join dimproduct dp on s.productkey=dp.productkey set s.product_name=dp.englishproductname;
select * from Sales order by OrderDateKey desc;
-- Add Customer Name and Unit Price to the Sales table
/* (a) Adding Customer Name, DATA being HUGE, I increased the DBMS CONNECTION READ TIMEOUT */
alter table sales add customer_name varchar(50);
update sales s inner join dimcustomer dc on s.customerkey=dc.customerkey set s.customer_name= concat_ws(' ',dc.firstname,dc.middlename,dc.lastname);

/* (b) Adding Unit Price */
alter table sales add unit_price2 decimal(10,2);
Update sales s inner join dimproduct dp on s.productkey=dp.productkey set s.unit_price2=dp.`Unit price`;

select * from Sales order by OrderDateKey desc;

-- Question 3 : Create date fields from Orderdatekey column
alter table sales add date Date;
desc sales;
/* Creating date field from orderdatekey
str_to_date is used since the orderdatekey's data type was not 'date' datatype */
update sales set date=str_to_date(orderdatekey,'%Y%m%d');

/* 3A-3D */
Alter table sales add year int, add month_no int, add month_fullname varchar(20), add quarter varchar(5);
update sales set year=year(date), month_no=month(date), month_fullname=monthname(date), quarter= concat("Q",quarter(date));

/* 3E-3I */
Alter table sales add yearmonth varchar(10), add week_dayno int, add week_dayname varchar(20), add financial_month int, add financial_quarter varchar(10);
update sales set yearmonth=date_format(date,'%Y-%b'), week_dayno=dayofweek(date), week_dayname=dayname(date), financial_month= MOD(MONTH(Date) + 5, 12) + 1, financial_quarter=CONCAT("Q", CEIL((MOD(MONTH(Date) + 5, 12) + 1) / 3));

-- Question 4 : Calculate the Sale Amount
alter table sales add sale_amount2 decimal(10,2);
update sales set sale_amount2= unit_price2 * orderquantity * (1-unitpricediscountpct);

-- Question 5 : Calculate the Production Cost
alter table sales add production_cost decimal(10,2);
update sales set production_cost= productstandardcost * orderquantity;

-- Question 6 : Calculate the Profit
alter table sales add Profit decimal (10,2);
update sales set profit = sale_amount2 - production_cost;

-- Sales and Profit Analysis
/* 1.  Yearly Sales and Profit: Used CTE to get the percentage for each year and rounded it off to 2 decimals */

with cte1 as (select Year, sum(sale_amount2) as Total_Sales from sales group by year order by Total_Sales desc)
select *, round(Total_Sales/(select sum(total_sales) from cte1) * 100,2) as Percentage from cte1 order by Percentage desc;

with cte3 as ( select Year, sum(Profit) as Total_Profit from sales group by year order by Total_Profit desc)
select *, round(total_profit/(select sum(total_profit) from cte3) * 100,2) as Percentage from cte3 order by Percentage desc;


/* 2. Sales vs Production cost (Monthly Profitability and Overall Profit Margin) */
with cte2 as (select Year, Month_Fullname, sum(sale_amount2) as Total_Sales, sum(production_cost) as Production_Cost, sum(Profit) as Profit from sales group by year, month_fullname, month_no order by year desc, month_no asc)
select *, round((Profit/Total_Sales) * 100,2) as Profit_Margin from cte2;

/* Overall Profit Margin */
select round(sum(profit)/sum(sale_amount2)*100,2) as Overall_Profit_Margin from sales;


-- Product Analysis
/* 1. Top 5 Products by Sales and Profit */
select Product_Name, sum(Sale_Amount2) as Total_Sales from sales group by product_name order by Total_sales desc limit 5;
select Product_Name, sum(Profit) as Total_Profit from sales group by product_name order by Total_Profit desc limit 5;

/* 2. Top 5 Products by Profit Margin */
with cte4 as (select Product_Name, sum(Profit) as Total_Profit, sum(sale_amount2) as Total_Sales from sales group by product_name)
select *, round((total_profit/total_sales)*100,2) as Profit_Margin from cte4 group by product_name order by profit_margin desc limit 5;


-- Customer and Region Analysis
/* 1. Top 5 Customers by Sales and Profit */
select customer_name, sum(sale_amount2) as Total_sales from sales group by customer_name order by Total_sales desc limit 5;
select customer_name, sum(profit) as Total_Profit from sales group by customer_name order by Total_Profit desc limit 5;

/* 2. Sales by Country */
Select st.salesterritorycountry, sum(sale_amount2) as Total_Sales from sales s inner join dimsalesterritory st on s.salesterritorykey=st.salesterritorykey 
group by st.salesterritorycountry order by total_sales desc;

-- Extras
/* 1.  Month wise Sales and Profit: Added month_no to the query or else the monthname would have sorted alphabetically */
select Year, Month_FullName, sum(sale_amount2) as Total_Sales from sales group by year , month_no, month_fullname order by year desc, month_no asc;
select Year, Month_FullName, sum(Profit) as Profit from sales group by year, month_no, month_FullName order by year desc, month_no asc;


/* 2.  Quarter wise Sales and Profit */
select Year, Quarter, sum(sale_amount2) as Total_Sales from sales group by year, quarter order by year desc, quarter asc;
select Year, Quarter, sum(profit) as Total_Profit from sales group by year, quarter order by year desc, quarter asc;


/* 3. Top 5 Customer by Profit Margin */
with cte5 as (select Customer_Name, sum(Profit) as Total_Profit, sum(sale_amount2) as Total_Sales from sales group by customer_name)
select *, round((total_profit/total_sales)*100,2) as Profit_Margin from cte5 group by customer_name order by profit_margin desc limit 5;

