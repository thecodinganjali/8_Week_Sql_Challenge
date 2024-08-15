# Case Study #1 - Danny's Diner 

<img src="https://github.com/user-attachments/assets/ebfd70f7-c141-497a-b630-654897683bdf" width="500" height="500">

### Introuction

Danny's Diner, a delightful restaurant launched in early 2021 by Danny, offers a menu of sushi, curry, and ramen. While Danny’s culinary skills are top-notch, he needs help with analyzing the basic customer data collected in the initial months to ensure the restaurant's success.

### Problem Statement
Danny seeks to unlock insights from customer data to understand their habits, spending, and favorite dishes. This will help him enhance the customer experience and evaluate the potential of expanding the loyalty program. Your challenge is to craft SQL queries and datasets that will provide Danny with the information he needs to make data-driven decisions.

 Sample datasets include
 1) Sales
 2) Menu
 3) Members

### Entity Relationship Diagram

Three main tables: Sales, Menu, and Members, linked through customer_id and product_id

![Screenshot (412)](https://github.com/user-attachments/assets/d68d4aff-d422-44b9-a069-348b3ca427d7)


### Case Study Questions 
#### 1)What is the total amount each customer spent at the restaurant?



```bash
select  sales.customer_id , sum(menu.price) as total_amount
from sales 
join menu
on sales.product_id = menu.product_id
group by sales.customer_id
order by total_amount desc ;
```


![1st](https://github.com/user-attachments/assets/fd284ccf-815c-4683-b49a-a7b3a70731c8)

####   2) How many days has each customer visited the restaurant?

```bash
select customer_id, count(distinct order_date) as No_of_days
from sales
group by sales.customer_id
order by No_of_days desc;

```

![2](https://github.com/user-attachments/assets/e79340d6-7c98-454d-bc8b-be7990a55200)



#### 3)What was the first item from the menu purchased by each customer?

```bash
select customer_id , product_name from 
(select customer_id, product_name , dense_rank () over (partition by customer_id order by order_date asc) as rn  
from sales 
join menu
on sales.product_id = menu.product_id) as a 
where rn = 1 ;


```
![3](https://github.com/user-attachments/assets/7f75ddb7-8562-4c97-b8f6-0fef4b78c6f5)



#### 4)What is the most purchased item on the menu and how many times was it purchased by all customers?

```bash
select menu.product_name , count(sales.product_id) as most_purchased from menu
join sales 
on menu.product_id = sales.product_id 
group by menu.product_name 
order by most_purchased desc
limit 1;

```

![4](https://github.com/user-attachments/assets/73c9e8fc-9e97-4909-ae13-46350c2561f9)


#### 5)Which item was the most popular for each customer?
```bash
select customer_id,  product_name ,order_count from
(select sales.customer_id, count( menu.product_id) as order_count, menu.product_name , dense_rank ()over( partition by  sales.customer_id  order by count(menu.product_id) desc) as rn
from sales
join menu 
on sales.product_id = menu.product_id
group by sales.customer_id ,menu.product_name ) as a 
where rn =1;

```

![5](https://github.com/user-attachments/assets/8d54f947-4bce-4ef4-b007-46b1a65ad6cf)


#### 6) Which item was purchased first by the customer after they became a member?

```bash
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

```
![6](https://github.com/user-attachments/assets/43722a65-0905-43f4-a764-6e199be6de98)


#### 7)Which item was purchased just before the customer became a member?

```bash
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
 

```

![7](https://github.com/user-attachments/assets/26d81914-0f77-41b7-93c4-d5edee4a9ea2)


#### 8) What is the total items and amount spent for each member before they became a member?

```bash
select sales.customer_id, count(sales.product_id) as total_items , sum(menu.price) as total_amount
FROM menu 
JOIN sales ON sales.product_id = menu.product_id
JOIN members  ON members.customer_id = sales.customer_id
where members.join_date > sales.order_date
GROUP by sales.customer_id
order by sales.customer_id ;
    
```

![8](https://github.com/user-attachments/assets/86cb4408-a560-4d7f-8d83-334cb3483bdf)


#### 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```bash
select sales.customer_id, 
sum(case when product_name = 'sushi' then price * 2 
else price 
end) * 10  as Total_points 
from sales 
join menu 
on sales.product_id = menu.product_id
group by sales.customer_id;
    
```

![9](https://github.com/user-attachments/assets/2bf9a31a-2791-4daa-bd95-7be1c8835faf)


### Key Insights

- **Customer Spending:** Customers spend different amounts at Danny's Diner. Some spend a lot, showing they might be loyal or high-value customers.

- **Customer Visits:** Customers visit the restaurant at different frequencies. Some come often, while others come less frequently.

- **First Purchases:** Knowing what customers buy first can help identify popular items and attract new customers.

- **Most Popular Item:** Identifying the most popular item on the menu can help manage inventory better and focus on what customers love.

- **Personalized Recommendations:** By knowing each customer’s favorite items, Danny can suggest personalized menu options to improve their dining experience.

- **Customer Loyalty:** Comparing purchases before and after joining the loyalty program helps see if the program is effective.

- **Bonus Points for New Members:** Giving new members 2x points in their first week encourages them to spend more and engage with the loyalty program.

- **Member Points:** Tracking how many points members earn helps assess their loyalty and plan rewards and promotions.

- **Data Visualization:** Using charts and graphs can make it easier to understand trends and make better decisions.

- **Customer Segmentation:** Analyzing spending habits helps group customers and create targeted marketing strategies.

- **Expanding Membership:** Insights from the data can improve the loyalty program and attract more members.

- **Inventory Management:** Knowing which items are popular helps manage stock better, reduce waste, and increase profits.

- **Menu Optimization:** Data helps evaluate which menu items perform well and decide on new dishes based on customer preferences.

- **Customer Engagement:** Understanding customer behavior helps find out what makes them come back and create better experiences.

- **Long-Term Growth:** Using data analysis helps make informed decisions that support the long-term success of Danny's Diner.

---

