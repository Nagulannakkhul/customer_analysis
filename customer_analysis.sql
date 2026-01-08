                ----------* customer_analysis_schema *--------------


------create table customer

create table customers(
						customer_id int primary key,
						signup_date date,
						country varchar(10),
						gender varchar(10)
					  );


------create table orders 

create table orders(
					order_id int primary key,
					customer_id int,
					order_date date,
					discount_applied boolean, 
					payment_type varchar(5)
					);

------create table products

Create table products(
	 				   product_id int primary key,
					   order_id int,
					   category varchar(15),
					   cost_price int
					   );


------create table products

create table order_items(
						order_id int,
						product_id int,
						quantity int,
						price numeric
					 );


select * from products;


-----1.what is the total revenue and total cost for each product?


select oi.order_id,sum(oi.quantity * oi.price) as revenue,
				   sum(oi.quantity * p.cost_price) as costs
from order_items oi
join products p on oi.product_id = p.product_id
group by 1


-----2.what are the total revenue, total cost, and resulting profit for each product?

with orders_result as (
		select oi.order_id,
			   sum(oi.quantity * oi.price) as revenue,
			   sum(oi.quantity * p.cost_price) as costs
	    from order_items oi	
		join products p on oi.product_id = p.product_id
		group by 1
)
select *,
		revenue - costs as profits
from orders_result;


-----3.which top country has the highest Customer?


with highest_customer as(
			select c.country,
				   c.customer_id,
				   sum(oi.quantity * oi.price) - sum(oi.quantity * p.cost_price) as revenue_costs
		    from customers c
			JOIN orders o ON c.customer_id = o.customer_id 
			JOIN order_items oi ON o.order_id = oi.order_id 
			JOIN products p ON oi.product_id = p.product_id
			group by 1,2
),
ranked as(
select *,
	 rank() over(partition by country order by revenue_costs desc) as rnak
from highest_customer
)
select *
from ranked
where rnak = 1;


-----4.How does applying a discount affect customer count and total profit?

select discount_applied,
	   count(distinct o.customer_id) as customers,
	   sum((oi.quantity * oi.price) - (oi.quantity * p.cost_price)) as total_profit
from orders o
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
group by discount_applied


-----5.How can we segment customers based on their profitability and discount usage?


with customer_behaviour as(
				select o.customer_id,
					   count(distinct o.order_id) as total_orders,
					   sum((oi.quantity * oi.price) - (oi.quantity * p.cost_price)) as total_profit,
					   sum(case when o.discount_applied then 1 else 0 end) as discount
			    from orders o
				join order_items oi on o.order_id = oi.order_id
				join products p on p.product_id = oi.product_id
				group by o.customer_id

)
select *, 
		case
		when total_profit >=400 and discount = 0 then 'high'
		when total_profit > 500 and discount >0 then 'medium'
		else 'low'
		end as  segment_customers
from customer_behaviour












