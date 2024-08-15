
# Case Study #3-Foodie-Fi 

<img src="https://github.com/user-attachments/assets/3a8fc54d-de1e-4f11-937d-113708d31d38" width="500" height="500">

### Introduction

Foodie-Fi is a subscription-based streaming service that offers unlimited on-demand access to exclusive food-related content. This case study involves analyzing subscription data to understand customer behavior, subscription trends, and the effectiveness of different plans.



### Entity Relationship Diagram


![Screenshot (428)](https://github.com/user-attachments/assets/2e2f30ea-a1a2-450f-99fe-f134187e21a9)


### Case Study Questions 
#### 1)Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
```bash
select s.customer_id, p.plan_name, s.start_date
from subscriptions as s 
join plans as p
on s.plan_id = p.plan_id
order by s.customer_id, s.start_date asc;

```

![1](https://github.com/user-attachments/assets/a2ed02d3-2779-4d93-bd24-8e9f15bf1d9c)

####   2) How many customers has Foodie-Fi ever had?

```bash
SELECT 
    COUNT( distinct customer_id) AS total_customers
FROM
    subscriptions;


```
![2nd](https://github.com/user-attachments/assets/ac04e74a-e2a8-49ac-8953-733f4f80c7c9)




#### 3)What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value.


```bash
SELECT 
    EXTRACT(MONTH FROM start_date) AS month_start,
    COUNT(*) AS trial_start
FROM
    subscriptions
WHERE
    plan_id = 0
GROUP BY month_start
ORDER BY month_start;


```
![3rd](https://github.com/user-attachments/assets/40b2b77c-3ac1-43f0-8321-4312d97a21fe)



#### 4)What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name


```bash
SELECT
  p.plan_name,
  p.plan_id,
  COUNT(*) AS event_count
FROM
  subscriptions s
JOIN
  plans p ON s.plan_id = p.plan_id
WHERE
  s.start_date > '2020-12-31' -- Filter for start dates after 2020
GROUP BY
  p.plan_name, p.plan_id
ORDER BY
  p.plan_name, p.plan_id;

```

![4th](https://github.com/user-attachments/assets/8d5c253b-9785-4c1d-8554-729361d5c73f)


#### 5) What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```bash
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) AS churned_customers,
    ROUND((COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id)), 1) AS churn_percentage
FROM 
    foodie_fi.subscriptions;

```

![5th](https://github.com/user-attachments/assets/7e681c29-1b2f-4074-9eeb-07b212e74678)


#### 6) How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?


```bash
WITH ranked_cte AS (
SELECT 
  sub.customer_id,  
  plans.plan_name, 
    LEAD(plans.plan_name) OVER ( 
    PARTITION BY sub.customer_id
    ORDER BY sub.start_date) AS next_plan
FROM subscriptions AS sub
JOIN plans 
  ON sub.plan_id = plans.plan_id
)

SELECT 
COUNT(customer_id) AS customers,
ROUND(100.0 * 
  COUNT(customer_id) 
  / (SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions)
) AS churn_percentage
FROM ranked_cte
WHERE plan_name = 'trial' 
AND next_plan = 'churn';

```
![6th](https://github.com/user-attachments/assets/1f1acd2d-b299-4615-82e4-e9258be66f13)


#### 7)What is the number and percentage of customer plans after their initial free trial?


```bash
WITH next_plans AS (
  SELECT 
    customer_id, 
    plan_id, 
    LEAD(plan_id) OVER(
      PARTITION BY customer_id 
      ORDER BY plan_id) AS next_plan_id
  FROM subscriptions
)

SELECT 
  next_plan_id AS plan_id, 
  COUNT(customer_id) AS after_free_customers,
  ROUND(100 * 
    COUNT(customer_id) 
    / (SELECT COUNT(DISTINCT customer_id) 
       FROM subscriptions), 1) AS after_percentage
FROM next_plans
WHERE next_plan_id IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan_id
ORDER BY next_plan_id

```

![7th](https://github.com/user-attachments/assets/895eb75c-b7bf-4300-b6c9-de7004aa3f3d)


#### 8)What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```bash

SELECT 
    p.plan_name,
    COUNT(DISTINCT s.customer_id) AS customer_count,
    ROUND(100.0 * COUNT(DISTINCT s.customer_id) / (SELECT 
                    COUNT(DISTINCT customer_id)
                FROM
                    subscriptions
                WHERE
                    start_date <= '2020-12-31'),
            1) AS percentage
FROM
    subscriptions s
        JOIN
    plans p ON s.plan_id = p.plan_id
WHERE
    s.start_date <= '2020-12-31'
GROUP BY p.plan_name , p.plan_id
ORDER BY p.plan_id;
    
```

![Screenshot (440)](https://github.com/user-attachments/assets/ac981e7a-f365-4976-b82c-8aaa52d954c2)


#### 9) How many customers have upgraded to an annual plan in 2020?
```bash
SELECT 
    COUNT(DISTINCT customer_id) AS upgraded_customers_count
FROM
    subscriptions
WHERE
    start_date >= '2020-01-01'
        AND start_date <= '2020-12-31'
        AND plan_id = 3; -- Plan ID 3 represents the annual pro plan    
```
![8th](https://github.com/user-attachments/assets/3f74bdac-5412-42c1-b87f-55adf32a087b)



#### 10) How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```bash
SELECT 
    COUNT(*) AS num_downgrades
FROM
    subscriptions prev
        JOIN
    subscriptions current ON prev.customer_id = current.customer_id
        AND prev.plan_id = 2
        AND current.plan_id = 1
        AND prev.start_date <= current.start_date
WHERE
    EXTRACT(YEAR FROM prev.start_date) = 2020;

```


![9th](https://github.com/user-attachments/assets/9dc7bcfb-4b8c-401a-bac4-52ed54d362a9)




### Key Insights

- **Customer Spending:** Customers at Foodie-Fi spend varying amounts. Some are high-value, which can indicate loyalty or greater engagement.

- **Customer Visits:** Customers visit Foodie-Fi at different rates. Some are frequent visitors, while others visit less often.

- **First Purchases:** Identifying the first items purchased can reveal popular choices and help attract new customers.

- **Most Popular Item:** Knowing the most frequently purchased item helps manage inventory and focus on popular content.

- **Personalized Recommendations:**  Understanding each customer’s favorite content allows for personalized recommendations, enhancing their experience.

- **Customer Loyalty:** Analyzing purchases before and after joining the loyalty program helps gauge its effectiveness.

- **Bonus Points for New Members:**  Offering 2x points in the first week encourages new members to spend more and engage with the platform.

- **Member Points:**  Tracking points earned by members helps evaluate their loyalty and plan targeted rewards.

- **Data Visualization:** Using charts and graphs simplifies trend analysis and decision-making.

- **Customer Segmentation:** Analyzing spending habits helps segment customers for targeted marketing strategies.

- **Expanding Membership:** Data-driven insights can enhance the loyalty program and attract more members.

- **Inventory Management:** Identifying popular content helps manage stock and reduce waste, leading to increased profits.

- **Content Optimization:** Data informs which content performs well and guides decisions on new offerings.

- **Customer Engagement:** Understanding customer behavior helps improve their experience and retention.

- **Long-Term Growth:** Data analysis supports informed decisions for sustainable growth and success of Foodie-Fi.

