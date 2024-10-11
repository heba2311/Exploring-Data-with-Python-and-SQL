select * from df_orders

--find top 10 highest revue generating products
SELECT top 10 Product_Id , sum(sale_price) as sales 
from df_orders
GROUP BY Product_Id
order by sales DESC




--find top 5 highest selling products in each region

SELECT region, product_id, total_sales
FROM (
    SELECT region,
           product_id,
           SUM(sale_price) AS total_sales,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rank
    FROM df_orders
    GROUP BY region, product_id
) AS ranked_products
WHERE rank <= 5


--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as (
select year(order_date) as order_year,month(order_date) as order_month,
sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
	)

select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month


--for each category which month had highest sales 
with cte as (
select category,format(order_date,'yyyy-MM') as order_year_month
, sum(sale_price) as sales 
from df_orders
group by category,format(order_date,'yyyy-MM')
--order by category,format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1