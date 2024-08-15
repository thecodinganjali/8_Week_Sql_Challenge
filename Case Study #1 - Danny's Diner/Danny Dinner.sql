-- 1)What is the total amount each customer spent at the restaurant?

select  sales.customer_id , sum(menu.price) as total_amount
from sales 
join menu
on sales.product_id = menu.product_id
group by sales.customer_id
order by total_amount desc ;

--  2)How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) as No_of_days
from sales
group by sales.customer_id
order by No_of_days desc;

--   3)What was the first item from the menu purchased by each customer?

select customer_id , product_name from 
(select customer_id, product_name , dense_rank () over (partition by customer_id order by order_date asc) as rn  
from sales 
join menu
on sales.product_id = menu.product_id) as a 
where rn = 1 ;


--  4) What is the most purchased item on the menu and how many times was it purchased by all customers?
select menu.product_name , count(sales.product_id) as most_purchased from menu
join sales 
on menu.product_id = sales.product_id 
group by menu.product_name 
order by most_purchased desc
limit 1;

-- 5) Which item was the most popular for each customer?
select customer_id,  product_name ,order_count from
(select sales.customer_id, count( menu.product_id) as order_count, menu.product_name , dense_rank ()over( partition by  sales.customer_id  order by count(menu.product_id) desc) as rn
from sales
join menu 
on sales.product_id = menu.product_id
group by sales.customer_id ,menu.product_name ) as a 
where rn =1;

--  6)Which item was purchased first by the customer after they became a member?
WITH RankedSales AS (
    SELECT 
        s.customer_id,
        m.product_name,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rn
    FROM sales s
    JOIN members mbr ON s.customer_id = mbr.customer_id
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.order_date > mbr.join_date
)
SELECT 
    customer_id,
    product_name
FROM RankedSales
WHERE rn = 1;

--   7)Which item was purchased just before the customer became a member?

WITH RankedSales AS (
    SELECT 
        sales.customer_id,
        menu.product_name,
        ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS rn
    FROM menu 
    JOIN sales ON sales.product_id = menu.product_id
	JOIN members  ON members.customer_id = sales.customer_id
    WHERE sales.order_date < members.join_date
)
SELECT 
    customer_id,
    product_name
FROM RankedSales
WHERE rn = 1;
 
--  8)What is the total items and amount spent for each member before they became a member?

select sales.customer_id, count(sales.product_id) as total_items , sum(menu.price) as total_amount
FROM menu 
JOIN sales ON sales.product_id = menu.product_id
JOIN members  ON members.customer_id = sales.customer_id
where members.join_date > sales.order_date
GROUP by sales.customer_id
order by sales.customer_id ;
    
-- 9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select sales.customer_id, 
sum(case when product_name = 'sushi' then price * 2 
else price 
end) * 10  as Total_points 
from sales 
join menu 
on sales.product_id = menu.product_id
group by sales.customer_id;

