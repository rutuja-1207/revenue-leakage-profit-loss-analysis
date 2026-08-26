CREATE TABLE revenue_leakage (
    order_id VARCHAR(50),
    order_date DATE,
    customer_id VARCHAR(50),
    product VARCHAR(100),
    category VARCHAR(100),
    region VARCHAR(50),
    city VARCHAR(100),
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    sales NUMERIC(12,2),
    discount_percent NUMERIC(5,2),
    cost_per_unit NUMERIC(12,2),
    delivery_cost NUMERIC(12,2),
    return_status VARCHAR(20),
    payment_method VARCHAR(50),
    payment_status VARCHAR(30),
    order_status VARCHAR(30),
    discount_amount NUMERIC(12,2),
    net_revenue NUMERIC(12,2),
    product_cost NUMERIC(12,2),
    total_cost NUMERIC(12,2),
    profit NUMERIC(12,2),
    profit_margin NUMERIC(8,2),
    discount_leakage NUMERIC(12,2),
    month VARCHAR(10)
);

select * from revenue_leakage

SELECT COUNT(*) 
FROM revenue_leakage;

SELECT *
FROM revenue_leakage
LIMIT 10;

SELECT 
    order_id,
    order_date,
    product,
    category,
    quantity,
    sales,
    discount_percent,
    total_cost,
    profit
FROM revenue_leakage
LIMIT 10;

--Total Orders
SELECT COUNT(*) AS total_orders
FROM revenue_leakage;

--Total Sales
SELECT SUM(sales) AS total_sales
FROM revenue_leakage;

--Total Discount
SELECT SUM(discount_amount) AS total_discount
FROM revenue_leakage;

--Total Net Revenue
SELECT SUM(net_revenue) AS total_net_revenue
FROM revenue_leakage;

--Total Cost
SELECT SUM(total_cost) AS total_cost
FROM revenue_leakage;

--Total Profit 
SELECT SUM(profit) AS total_profit
FROM revenue_leakage;

--loss making product
SELECT
    order_id,
    product,
    category,
    region,
    sales,
    discount_percent,
    net_revenue,
    total_cost,
    profit
FROM revenue_leakage
WHERE profit < 0;


--Count loss-making orders
SELECT COUNT(*) AS loss_making_orders
FROM revenue_leakage
WHERE profit < 0;

--Calculate total loss
SELECT
    ABS(SUM(profit)) AS total_loss
FROM revenue_leakage
WHERE profit < 0;

--Find the biggest losses 🔥
SELECT
    order_id,
    product,
    region,
    sales,
    discount_percent,
    total_cost,
    profit
FROM revenue_leakage
WHERE profit < 0
ORDER BY profit ASC
LIMIT 10;

--High Discount + Loss-Making Orders

--Find the orders
SELECT
    order_id,
    product,
    category,
    region,
    sales,
    discount_percent,
    discount_amount,
    net_revenue,
    total_cost,
    profit
FROM revenue_leakage
WHERE discount_percent >= 20
  AND profit < 0
ORDER BY profit ASC;

--Count these orders
SELECT COUNT(*) AS high_discount_loss_orders
FROM revenue_leakage
WHERE discount_percent >= 20
  AND profit < 0;

--Calculate total profit loss
SELECT
    ABS(SUM(profit)) AS high_discount_profit_loss
FROM revenue_leakage
WHERE discount_percent >= 20
  AND profit < 0;

--Find the biggest leakage orders 
SELECT
    order_id,
    product,
    sales,
    discount_percent,
    discount_amount,
    total_cost,
    profit
FROM revenue_leakage
WHERE discount_percent >= 20
  AND profit < 0
ORDER BY profit ASC
LIMIT 10;

--Product-wise summary
SELECT
    product,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(net_revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY product
ORDER BY total_profit DESC;

--Loss-making products 

SELECT
    product,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY product
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

--Top 10 profitable products
SELECT
    product,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY product
ORDER BY total_profit DESC
LIMIT 10;

--Region Summary
SELECT
    region,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(net_revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY region
ORDER BY total_profit DESC;

--Loss-making Regions 
SELECT
    region,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY region
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

--Region with highest profit
SELECT
    region,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY region
ORDER BY total_profit DESC
LIMIT 1;

--Return Analysis
SELECT COUNT(*) AS returned_orders
FROM revenue_leakage
WHERE return_status = 'Yes';

--Return Rate %
SELECT
    COUNT(*) FILTER (WHERE return_status = 'Yes') * 100.0
    / COUNT(*) AS return_rate
FROM revenue_leakage;

--Return by Product 
SELECT
    product,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE return_status = 'Yes') AS returned_orders,
    ROUND(
        COUNT(*) FILTER (WHERE return_status = 'Yes') * 100.0
        / COUNT(*),
        2
    ) AS return_rate
FROM revenue_leakage
GROUP BY product
ORDER BY return_rate DESC;

--Returned Orders Profit
SELECT
    COUNT(*) AS returned_orders,
    SUM(net_revenue) AS returned_revenue,
    SUM(total_cost) AS returned_cost,
    SUM(profit) AS returned_profit
FROM revenue_leakage
WHERE return_status = 'Yes';

--Discount Analysis

--Product-wise Discount Analysis
SELECT
    product,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(discount_amount) AS total_discount,
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY product
ORDER BY total_discount DESC;

--Products with highest average discount
SELECT
    product,
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    SUM(discount_amount) AS total_discount,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY product
ORDER BY avg_discount_percent DESC
LIMIT 10;

--High Discount + Negative Profit analysis:

SELECT
    product,
    COUNT(*) AS total_orders,
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    SUM(discount_amount) AS total_discount,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY product
HAVING AVG(discount_percent) >= 20
   AND SUM(profit) < 0
ORDER BY total_profit ASC;

--Total Discount Given
SELECT
    SUM(discount_amount) AS total_discount_given
FROM revenue_leakage;

--Delivery Cost Analysis
--Region-wise Delivery Cost
SELECT
    region,
    COUNT(*) AS total_orders,
    SUM(delivery_cost) AS total_delivery_cost,
    ROUND(AVG(delivery_cost), 2) AS avg_delivery_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY region
ORDER BY total_delivery_cost DESC;

--Highest Average Delivery Cost
SELECT
    region,
    ROUND(AVG(delivery_cost), 2) AS avg_delivery_cost
FROM revenue_leakage
GROUP BY region
ORDER BY avg_delivery_cost DESC;

--High Delivery Cost + Negative Profit 🔥
SELECT
    region,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_cost), 2) AS avg_delivery_cost,
    SUM(delivery_cost) AS total_delivery_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY region
HAVING AVG(delivery_cost) > (
    SELECT AVG(delivery_cost)
    FROM revenue_leakage
)
AND SUM(profit) < 0
ORDER BY total_profit ASC;

--Highest Delivery Cost Orders
SELECT
    order_id,
    product,
    region,
    sales,
    delivery_cost,
    profit
FROM revenue_leakage
ORDER BY delivery_cost DESC
LIMIT 10;

--Customer-wise Profit Analysis
--Customer Summary
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(net_revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY customer_id
ORDER BY total_profit DESC;

--Lowest Profit Customers 
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY customer_id
ORDER BY total_profit ASC
LIMIT 10;

--Loss-making Customers
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY customer_id
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- High Sales + Low Profit 
-- interesting analysis:

SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(net_revenue) AS total_revenue,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY customer_id
HAVING SUM(sales) > (
    SELECT AVG(customer_sales)
    FROM (
        SELECT SUM(sales) AS customer_sales
        FROM revenue_leakage
        GROUP BY customer_id
    ) AS customer_summary
)
AND SUM(profit) < 0
ORDER BY total_profit ASC;

--Monthly Sales & Profit Analysis
--Monthly Summary
SELECT
    month,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    SUM(discount_amount) AS total_discount,
    SUM(net_revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY month
ORDER BY month;

--Lowest Profit Months 
SELECT
    month,
    SUM(sales) AS total_sales,
    SUM(discount_amount) AS total_discount,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY month
ORDER BY total_profit ASC
LIMIT 5;

--Highest Discount Months 
SELECT
    month,
    SUM(sales) AS total_sales,
    SUM(discount_amount) AS total_discount,
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY month
ORDER BY total_discount DESC
LIMIT 5;

--High Sales + Low Profit 
SELECT
    month,
    SUM(sales) AS total_sales,
    SUM(net_revenue) AS total_revenue,
    SUM(total_cost) AS total_cost,
    SUM(profit) AS total_profit
FROM revenue_leakage
GROUP BY month
ORDER BY total_profit ASC;

--Final Revenue Leakage Summary
--Overall KPI Summary
SELECT
    COUNT(*) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(discount_amount), 2) AS total_discount,
    ROUND(SUM(net_revenue), 2) AS total_net_revenue,
    ROUND(SUM(total_cost), 2) AS total_cost,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(*) FILTER (WHERE profit < 0) AS loss_making_orders,
    COUNT(*) FILTER (WHERE return_status = 'Yes') AS returned_orders
FROM revenue_leakage;

--Overall Profit Margin
SELECT
    ROUND(
        SUM(profit) * 100.0 / NULLIF(SUM(net_revenue), 0),
        2
    ) AS overall_profit_margin
FROM revenue_leakage;

--Total Loss from Loss-Making Orders
SELECT
    ROUND(
        ABS(SUM(profit)),
        2
    ) AS total_loss
FROM revenue_leakage
WHERE profit < 0;

--High Discount + Loss
SELECT
    COUNT(*) AS high_discount_loss_orders,
    ROUND(
        ABS(SUM(profit)),
        2
    ) AS profit_loss
FROM revenue_leakage
WHERE discount_percent >= 20
  AND profit < 0;

--Return + Loss Orders
SELECT
    COUNT(*) AS returned_loss_orders,
    ROUND(
        ABS(SUM(profit)),
        2
    ) AS profit_loss
FROM revenue_leakage
WHERE return_status = 'Yes'
  AND profit < 0;

