/*
EDA and Business Questions - Olist_DWH
Source table: dbo.sales_copy
Run this script in SQL Server Management Studio (SSMS) with Olist_DWH selected.
*/

USE Olist_DWH;
GO
-- Step 0: Create the working copy of the sales view (run ONCE only)
-- Note: dbo.sales_copy is a physical copy of gold.fact_sales, created to improve query performance.
IF OBJECT_ID('dbo.sales_copy', 'U') IS NULL
BEGIN
    SELECT order_id, product_key, seller_key, order_purchase_timestamp,
           order_delivered_customer_date, order_estimated_delivery_date,
           order_status, sales_amount, freight_value, total_item_amount
    INTO dbo.sales_copy
    FROM gold.fact_sales;
END
GO
/* =========================
   PART 1: EDA
   ========================= */

-- 1. Overall data overview
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    COUNT(DISTINCT product_key) AS distinct_products,
    COUNT(DISTINCT seller_key) AS distinct_sellers,
    SUM(sales_amount) AS total_sales,
    SUM(freight_value) AS total_freight,
    SUM(total_item_amount) AS total_item_amount,
    MIN(order_purchase_timestamp) AS first_purchase_date,
    MAX(order_purchase_timestamp) AS last_purchase_date
FROM dbo.sales_copy;
GO

-- 2. Missing values
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_product_key,
    SUM(CASE WHEN seller_key IS NULL THEN 1 ELSE 0 END) AS null_seller_key,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase_timestamp,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivery_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_delivery_date,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
    SUM(CASE WHEN sales_amount IS NULL THEN 1 ELSE 0 END) AS null_sales_amount,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight_value,
    SUM(CASE WHEN total_item_amount IS NULL THEN 1 ELSE 0 END) AS null_total_item_amount
FROM dbo.sales_copy;
GO

-- 3. Duplicate order/product/seller combinations (review results if any)
SELECT order_id, product_key, seller_key, COUNT(*) AS row_count
FROM dbo.sales_copy
GROUP BY order_id, product_key, seller_key
HAVING COUNT(*) > 1
ORDER BY row_count DESC;
GO

-- 4. Order status distribution
SELECT
    order_status,
    COUNT(*) AS row_count,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM dbo.sales_copy
GROUP BY order_status
ORDER BY row_count DESC;
GO

-- 5. Check invalid or unusual numeric values
SELECT
    SUM(CASE WHEN sales_amount < 0 THEN 1 ELSE 0 END) AS negative_sales_rows,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS negative_freight_rows,
    SUM(CASE WHEN total_item_amount < 0 THEN 1 ELSE 0 END) AS negative_total_amount_rows
FROM dbo.sales_copy;
GO

-- 6. Check date consistency
SELECT
    SUM(CASE WHEN order_delivered_customer_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS delivery_before_purchase,
    SUM(CASE WHEN order_estimated_delivery_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS estimated_date_before_purchase,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS rows_without_delivery_date
FROM dbo.sales_copy;
GO

-- 7. Numeric summary (min, avg, max) to detect outliers
SELECT
    MIN(sales_amount) AS min_sales, AVG(sales_amount) AS avg_sales, MAX(sales_amount) AS max_sales,
    MIN(freight_value) AS min_freight, AVG(freight_value) AS avg_freight, MAX(freight_value) AS max_freight
FROM dbo.sales_copy;
GO

-- 8. Dimension tables check (row counts and missing values)
SELECT
    (SELECT COUNT(*) FROM gold.dim_products) AS total_products,
    (SELECT COUNT(*) FROM gold.dim_products WHERE category_name IS NULL) AS products_null_category,
    (SELECT COUNT(*) FROM gold.dim_sellers) AS total_sellers,
    (SELECT COUNT(*) FROM gold.dim_sellers WHERE seller_state IS NULL) AS sellers_null_state;
GO


/* =========================
   PART 2: BUSINESS QUESTIONS
   ========================= */

-- Q1. What are the monthly sales and order counts (delivered orders only)?
SELECT
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS year_month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(freight_value) AS total_freight,
    SUM(total_item_amount) AS total_item_amount
FROM dbo.sales_copy
WHERE order_purchase_timestamp IS NOT NULL
  AND order_status = 'delivered'
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY year_month;
GO
-- Q2. Which order statuses have the highest number of rows and orders?
SELECT
    order_status,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales_amount) AS sales_amount,
    SUM(freight_value) AS freight_value
FROM dbo.sales_copy
GROUP BY order_status
ORDER BY total_orders DESC;
GO

-- Q3. What percentage of distinct orders have been delivered?
WITH OrderStatus AS (
    SELECT
        order_id,
        MAX(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS is_delivered
    FROM dbo.sales_copy
    GROUP BY order_id
)
SELECT
    COUNT(*) AS total_orders,
    SUM(is_delivered) AS delivered_orders,
    CAST(100.0 * SUM(is_delivered) / NULLIF(COUNT(*), 0) AS DECIMAL(6,2)) AS delivered_order_percentage
FROM OrderStatus;
GO

-- Q4. How long does delivery take on average, in days?
SELECT
    AVG(CAST(DATEDIFF(MINUTE, order_purchase_timestamp, order_delivered_customer_date) AS FLOAT) / 1440.0) AS avg_delivery_days,
    MIN(CAST(DATEDIFF(MINUTE, order_purchase_timestamp, order_delivered_customer_date) AS FLOAT) / 1440.0) AS min_delivery_days,
    MAX(CAST(DATEDIFF(MINUTE, order_purchase_timestamp, order_delivered_customer_date) AS FLOAT) / 1440.0) AS max_delivery_days
FROM dbo.sales_copy
WHERE order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp;
GO

-- Q5. Are delivered orders early, on time, or late compared with the estimated date?
WITH Orders AS (
    SELECT
        order_id,
        MAX(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS is_delivered,
        CAST(MAX(order_delivered_customer_date) AS DATE) AS delivered_date,
        CAST(MAX(order_estimated_delivery_date) AS DATE) AS estimated_date
    FROM dbo.sales_copy
    GROUP BY order_id
)
SELECT
    CASE
        WHEN delivered_date < estimated_date THEN 'Early'
        WHEN delivered_date = estimated_date THEN 'On time'
        WHEN delivered_date > estimated_date THEN 'Late'
        ELSE 'Missing delivery/estimated date'
    END AS delivery_performance,
    COUNT(*) AS total_orders
FROM Orders
WHERE is_delivered = 1
GROUP BY
    CASE
        WHEN delivered_date < estimated_date THEN 'Early'
        WHEN delivered_date = estimated_date THEN 'On time'
        WHEN delivered_date > estimated_date THEN 'Late'
        ELSE 'Missing delivery/estimated date'
    END
ORDER BY total_orders DESC;
GO


-- Q6. What is the average freight value by order status?
SELECT
    order_status,
    COUNT(*) AS row_count,
    AVG(freight_value) AS average_freight,
    SUM(freight_value) AS total_freight
FROM dbo.sales_copy
GROUP BY order_status
ORDER BY average_freight DESC;
GO

-- Q7. How does total sales compare with freight over time (delivered orders only)?
SELECT
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS year_month,
    SUM(sales_amount) AS total_sales,
    SUM(freight_value) AS total_freight,
    CAST(100.0 * SUM(freight_value) / NULLIF(SUM(sales_amount), 0) AS DECIMAL(8,2)) AS freight_as_percent_of_sales
FROM dbo.sales_copy
WHERE order_purchase_timestamp IS NOT NULL
  AND order_status = 'delivered'
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY year_month;
GO
-- Q8. What is the distribution of orders by delivery-date availability?
SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL THEN 'Missing delivery date'
        ELSE 'Delivery date available'
    END AS delivery_date_status,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM dbo.sales_copy
GROUP BY
    CASE
        WHEN order_delivered_customer_date IS NULL THEN 'Missing delivery date'
        ELSE 'Delivery date available'
    END;
GO



-- Q9. What are the top 10 product categories by sales?
SELECT TOP 10
    p.category_name,
    COUNT(DISTINCT s.order_id) AS total_orders,
    SUM(s.sales_amount) AS total_sales
FROM dbo.sales_copy s
JOIN gold.dim_products p ON s.product_key = p.product_key
WHERE s.order_status = 'delivered'
GROUP BY p.category_name
ORDER BY total_sales DESC;
GO

-- Q10. What are the top 10 seller states by sales?
SELECT TOP 10
    d.seller_state,
    COUNT(DISTINCT s.order_id) AS total_orders,
    SUM(s.sales_amount) AS total_sales
FROM dbo.sales_copy s
JOIN gold.dim_sellers d ON s.seller_key = d.seller_key
WHERE s.order_status = 'delivered'
GROUP BY d.seller_state
ORDER BY total_sales DESC;
GO

-- Q11. Who are the top 10 sellers by sales?
SELECT TOP 10
    s.seller_key,
    d.seller_city,
    d.seller_state,
    COUNT(DISTINCT s.order_id) AS total_orders,
    SUM(s.sales_amount) AS total_sales
FROM dbo.sales_copy s
JOIN gold.dim_sellers d ON s.seller_key = d.seller_key
WHERE s.order_status = 'delivered'
GROUP BY s.seller_key, d.seller_city, d.seller_state
ORDER BY total_sales DESC;
GO

-- Q12. What is the average order value (AOV) for delivered orders?
SELECT
    SUM(sales_amount) / NULLIF(COUNT(DISTINCT order_id), 0) AS avg_order_value
FROM dbo.sales_copy
WHERE order_status = 'delivered';
GO

-- Q13. Which product categories have the highest late-delivery rate?
SELECT TOP 10
    p.category_name,
    COUNT(*) AS delivered_items,
    SUM(CASE WHEN CAST(s.order_delivered_customer_date AS DATE) > CAST(s.order_estimated_delivery_date AS DATE) THEN 1 ELSE 0 END) AS late_items,
    CAST(100.0 * SUM(CASE WHEN CAST(s.order_delivered_customer_date AS DATE) > CAST(s.order_estimated_delivery_date AS DATE) THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS late_percentage
FROM dbo.sales_copy s
JOIN gold.dim_products p ON s.product_key = p.product_key
WHERE s.order_status = 'delivered'
  AND s.order_delivered_customer_date IS NOT NULL
GROUP BY p.category_name
HAVING COUNT(*) >= 100
ORDER BY late_percentage DESC;
GO

-- Q14. What is the cancellation rate by seller state?
SELECT TOP 10
    d.seller_state,
    COUNT(DISTINCT s.order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN s.order_status = 'canceled' THEN s.order_id END) AS canceled_orders,
    CAST(100.0 * COUNT(DISTINCT CASE WHEN s.order_status = 'canceled' THEN s.order_id END) / COUNT(DISTINCT s.order_id) AS DECIMAL(5,2)) AS cancel_percentage
FROM dbo.sales_copy s
JOIN gold.dim_sellers d ON s.seller_key = d.seller_key
GROUP BY d.seller_state
HAVING COUNT(DISTINCT s.order_id) >= 100
ORDER BY cancel_percentage DESC;
GO