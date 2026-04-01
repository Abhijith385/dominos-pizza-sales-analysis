create database dominos_pizza;
use dominos_pizza;
select * from transactions;
select * from products;
select * from stores;

-- renaming column names with special characters
alter table transactions
rename column ï»¿transaction_id to transaction_id;

alter table products
rename column ï»¿product_id to product_id;

alter table stores
rename column ï»¿store_id to store_id;


-- checking data type of each column
describe transactions;

-- changing data types
-- 1. changing data type of transaction_date column

UPDATE transactions
SET transaction_date=str_to_date(transaction_date,"%Y-%m-%d");

alter table transactions
modify column transaction_date date;

-- 2. changing data type of transaction_time column

UPDATE transactions
SET transaction_time=str_to_time(transaction_date,"%Y-%m-%d");

alter table transactions
modify column transaction_time time;

-- Q1.Total sales for each month and mom% change

with cte as (select month(t.transaction_date) as month,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join products p on p.product_id=t.product_id
group by month(t.transaction_date))
    select *,(total_sales-lag(total_sales,1) over(order by month)) / lag(total_sales,1) over(order by month) *100 as mom_percentage_change
    from cte;
    

-- Q2.Total Quantity sold for each month and mom% change

select month(transaction_date) as month,
		sum(transaction_qty) total_quantity_sold,
        (sum(transaction_qty)-lag(sum(transaction_qty),1) over(order by month(transaction_date )))/
        lag(sum(transaction_qty),1) over(order by month(transaction_date )) *100 as mom_percentage_change
from transactions
group by month(transaction_date);

-- Q3.Total orders for each month and mom% change

select month(transaction_date) as month,
		count(*) total_orders,
        (count(*)-lag(count(*),1) over(order by month(transaction_date )))/
        lag(count(*),1) over(order by month(transaction_date )) *100 as mom_percentage_change
from transactions
group by month(transaction_date);

-- Q4. find the sales for each date

select t.transaction_date as date,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join products p on p.product_id=t.product_id
group by t.transaction_date;

-- Q5-find the average sales for each month

select  month(t.transaction_date) as month
		,round(sum(t.transaction_qty*p.unit_price)/count(distinct transaction_date),0) as average_sales
from transactions t
left join products p on p.product_id=t.product_id
group by month(t.transaction_date);

-- Q6 Compare the daily sales with the average sales for each month

with cte2 as 
(with cte1 as (select month(t.transaction_date) month,day(transaction_date) day,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join products p on p.product_id=t.product_id
group by month(t.transaction_date),day(transaction_date))
		select *,round(avg(total_sales) over(partition by month),0) as avg_sales
        from cte1)
        select month,day,total_sales,case
					when total_sales<avg_sales then "below average sales"
                    when total_sales=avg_sales then "average sales"
                    else "above average sales"
                    end as sales_status
        from cte2;

-- Q7 find the sales for weekends and weekdays

select case
		when dayofweek(t.transaction_date) in(1,7) then "weekend"
        else "weekday"
        end as daytype,
        sum(t.transaction_qty*p.unit_price) as total_sales,
       round( sum(t.transaction_qty*p.unit_price)/count(distinct t.transaction_date),0) as avg_sales
from transactions t 
left join products p on p.product_id=t.product_id
group by case
		when dayofweek(t.transaction_date) in(1,7) then "weekend"
        else "weekday"
        end;
        
        
-- Q8 find the total sales for each store loaction

select  s.store_location,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join stores s on s.store_id=t.store_id
left join products p on p.product_id=t.product_id
group by s.store_location
order by sum(t.transaction_qty*p.unit_price)  desc;

-- Q9 Find the total sales for each product category

select  p.product_category,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join products p on p.product_id=t.product_id
group by p.product_category
order by sum(t.transaction_qty*p.unit_price)  desc;


-- Q10  Top 3 products by sales

select   p.product_name,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join products p on p.product_id=t.product_id
group by p.product_name
order by sum(t.transaction_qty*p.unit_price)  desc
limit 3;


-- Q11  find the total sales by day and hour
        
        
select   dayname(t.transaction_date) as day,hour(t.transaction_time) as hour
,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join products p on p.product_id=t.product_id
group by dayname(t.transaction_date),hour(t.transaction_time);

-- Q12 find the total sales for each day

select   dayname(t.transaction_date) as day
,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join products p on p.product_id=t.product_id
group by dayname(t.transaction_date);


-- Q13 find the total sales by each hour

select hour(t.transaction_time) as hour
,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t
left join products p on p.product_id=t.product_id
group by hour(t.transaction_time);


select count(*) from stores;

-- Q14 Compare prime vs regular location wise sales

select s.location_type ,sum(t.transaction_qty*p.unit_price) as total_sales
from transactions t 
left join stores s on s.store_id=t.store_id
left join products p on p.product_id=t.product_id
group by s.location_type


        










