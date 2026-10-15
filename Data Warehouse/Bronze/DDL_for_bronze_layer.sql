CREATE SCHEMA Bronze;
CREATE SCHEMA Silver;
CREATE SCHEMA Gold;
----------------------------------
--DDL for Bronze layer

CREATE TABLE Bronze.Customers (
    customer_id NVARCHAR(255),
    customer_unique_id NVARCHAR(255),
    customer_zip_code_prefix NVARCHAR(255),
    customer_city NVARCHAR(255),
    customer_state NVARCHAR(255)
);

CREATE TABLE Bronze.Geolocation (
    geolocation_zip_code_prefix NVARCHAR(255),
    geolocation_lat NVARCHAR(255),
    geolocation_lng NVARCHAR(255),
    geolocation_city NVARCHAR(255),
    geolocation_state NVARCHAR(255)
);

CREATE TABLE Bronze.Order_Items (
    order_id NVARCHAR(255),
    order_item_id NVARCHAR(255),
    product_id NVARCHAR(255),
    seller_id NVARCHAR(255),
    shipping_limit_date NVARCHAR(255),
    price NVARCHAR(255),
    freight_value NVARCHAR(255)
);

CREATE TABLE Bronze.Order_Payments (
    order_id NVARCHAR(255),
    payment_sequential NVARCHAR(255),
    payment_type NVARCHAR(255),
    payment_installments NVARCHAR(255),
    payment_value NVARCHAR(255)
);

CREATE TABLE Bronze.Order_Reviews (
    review_id NVARCHAR(255),
    order_id NVARCHAR(255),
    review_score NVARCHAR(255),
    review_comment_title NVARCHAR(MAX),
    review_comment_message NVARCHAR(MAX),
    review_creation_date NVARCHAR(255),
    review_answer_timestamp NVARCHAR(255)
);

CREATE TABLE Bronze.Orders (
    order_id NVARCHAR(255),
    customer_id NVARCHAR(255),
    order_status NVARCHAR(255),
    order_purchase_timestamp NVARCHAR(255),
    order_approved_at NVARCHAR(255),
    order_delivered_carrier_date NVARCHAR(255),
    order_delivered_customer_date NVARCHAR(255),
    order_estimated_delivery_date NVARCHAR(255)
);

CREATE TABLE Bronze.Products (
    product_id NVARCHAR(255),
    product_category_name NVARCHAR(255),
    product_name_lenght NVARCHAR(255),
    product_description_lenght NVARCHAR(255),
    product_photos_qty NVARCHAR(255),
    product_weight_g NVARCHAR(255),
    product_length_cm NVARCHAR(255),
    product_height_cm NVARCHAR(255),
    product_width_cm NVARCHAR(255)
);

CREATE TABLE Bronze.Sellers (
    seller_id NVARCHAR(255),
    seller_zip_code_prefix NVARCHAR(255),
    seller_city NVARCHAR(255),
    seller_state NVARCHAR(255)
);

CREATE TABLE Bronze.Category_Translation (
    product_category_name NVARCHAR(255),
    product_category_name_english NVARCHAR(255)
);
