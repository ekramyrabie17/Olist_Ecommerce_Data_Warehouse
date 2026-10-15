CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    customer_lat,
    customer_lng
FROM (
    SELECT DISTINCT 
        c.customer_id,
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        g.geolocation_lat AS customer_lat,
        g.geolocation_lng AS customer_lng
    FROM silver.customers c
    LEFT JOIN silver.geolocation g 
        ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
) t;
GO

CREATE OR ALTER VIEW gold.dim_sellers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_key,
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    seller_lat,
    seller_lng
FROM (
    SELECT DISTINCT 
        s.seller_id,
        s.seller_zip_code_prefix,
        s.seller_city,
        s.seller_state,
        g.geolocation_lat AS seller_lat,
        g.geolocation_lng AS seller_lng
    FROM silver.sellers s
    LEFT JOIN silver.geolocation g 
        ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
) t;
GO

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    product_id,
    category_name,
    weight_g,
    length_cm,
    height_cm,
    width_cm
FROM (
    SELECT DISTINCT 
        p.product_id,
        p.product_category_name AS category_name,
        p.product_weight_g AS weight_g,
        p.product_length_cm AS length_cm,
        p.product_height_cm AS height_cm,
        p.product_width_cm AS width_cm
    FROM silver.products p
) t;
GO

SELECT *
FROM gold.fact_sales;

SELECT *
FROM gold.dim_sellers;

SELECT *
FROM gold.dim_products


