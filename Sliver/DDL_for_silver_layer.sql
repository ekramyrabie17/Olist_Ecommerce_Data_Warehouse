CREATE TABLE silver.customers (
    customer_id NVARCHAR(100),
    customer_unique_id NVARCHAR(100),
    customer_zip_code_prefix NVARCHAR(20),
    customer_city NVARCHAR(100),
    customer_state NVARCHAR(10),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.geolocation (
    geolocation_zip_code_prefix NVARCHAR(20),
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city NVARCHAR(100),
    geolocation_state NVARCHAR(10),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.order_items (
    order_id NVARCHAR(100),
    order_item_id INT,
    product_id NVARCHAR(100),
    seller_id NVARCHAR(100),
    shipping_limit_date DATETIME2,
    price FLOAT,                
    freight_value FLOAT,         
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.order_payments (
    order_id NVARCHAR(100),
    payment_sequential INT,
    payment_type NVARCHAR(50),
    payment_installments INT,
    payment_value FLOAT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.order_reviews (
    review_id NVARCHAR(100),
    order_id NVARCHAR(100),
    review_score INT,
    review_comment_title NVARCHAR(255),
    review_comment_message NVARCHAR(MAX),
    review_creation_date DATETIME2,
    review_answer_timestamp DATETIME2,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.orders (
    order_id NVARCHAR(100),
    customer_id NVARCHAR(100),
    order_status NVARCHAR(50),
    order_purchase_timestamp DATETIME2,
    order_approved_at DATETIME2,
    order_delivered_carrier_date DATETIME2,
    order_delivered_customer_date DATETIME2,
    order_estimated_delivery_date DATETIME2,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.products (
    product_id NVARCHAR(100),
    product_category_name NVARCHAR(255),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.sellers (
    seller_id NVARCHAR(100),
    seller_zip_code_prefix NVARCHAR(20),
    seller_city NVARCHAR(100),
    seller_state NVARCHAR(10),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.category_translation (
    product_category_name NVARCHAR(255),
    product_category_name_english NVARCHAR(255),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
