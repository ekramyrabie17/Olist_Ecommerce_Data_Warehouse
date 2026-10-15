CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    BEGIN TRY
        PRINT 'Loading Silver Layer (Olist Dataset - Fully Optimized)';

       
        PRINT '>> Cleaning & Inserting Into: silver.customers';
        TRUNCATE TABLE silver.customers;
        INSERT INTO silver.customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
        SELECT 
            TRIM(customer_id), TRIM(customer_unique_id), TRIM(customer_zip_code_prefix),
            LOWER(TRIM(customer_city)), UPPER(TRIM(customer_state))
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_unique_id) AS flag_last
            FROM bronze.customers WHERE customer_id IS NOT NULL
        ) t WHERE flag_last = 1;

        
        PRINT '>> Cleaning & Inserting Into: silver.geolocation';
        TRUNCATE TABLE silver.geolocation;
        INSERT INTO silver.geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
        SELECT 
            TRIM(geolocation_zip_code_prefix),
            AVG(TRY_CAST(geolocation_lat AS FLOAT)),
            AVG(TRY_CAST(geolocation_lng AS FLOAT)),
            MIN(LOWER(TRIM(geolocation_city))),
            MIN(UPPER(TRIM(geolocation_state)))
        FROM bronze.geolocation
        WHERE geolocation_zip_code_prefix IS NOT NULL
          AND TRY_CAST(geolocation_lat AS FLOAT) BETWEEN -90 AND 90   
          AND TRY_CAST(geolocation_lng AS FLOAT) BETWEEN -180 AND 180 
        GROUP BY geolocation_zip_code_prefix;

        
        PRINT '>> Cleaning & Inserting Into: silver.order_items';
        TRUNCATE TABLE silver.order_items;
        INSERT INTO silver.order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
        SELECT 
            TRIM(order_id),
            TRY_CAST(order_item_id AS INT),
            TRIM(product_id),
            TRIM(seller_id),
            TRY_CAST(shipping_limit_date AS DATETIME2),
            TRY_CAST(price AS FLOAT),
            TRY_CAST(freight_value AS FLOAT)
        FROM bronze.order_items
        WHERE order_id IS NOT NULL;

        -- 4. المدفوعات
        PRINT '>> Cleaning & Inserting Into: silver.order_payments';
        TRUNCATE TABLE silver.order_payments;
        INSERT INTO silver.order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
        SELECT 
            TRIM(order_id),
            TRY_CAST(payment_sequential AS INT),
            LOWER(TRIM(payment_type)),
            ISNULL(TRY_CAST(payment_installments AS INT), 1),
            ISNULL(TRY_CAST(payment_value AS FLOAT), 0)
        FROM bronze.order_payments;

     
        PRINT '>> Cleaning & Inserting Into: silver.order_reviews';
        TRUNCATE TABLE silver.order_reviews;
        INSERT INTO silver.order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
        SELECT 
            TRIM(review_id), TRIM(order_id),
            CASE WHEN TRY_CAST(review_score AS INT) BETWEEN 1 AND 5 THEN TRY_CAST(review_score AS INT) ELSE NULL END,
            TRIM(review_comment_title), TRIM(review_comment_message),
            TRY_CAST(review_creation_date AS DATETIME2), TRY_CAST(review_answer_timestamp AS DATETIME2)
        FROM bronze.order_reviews
        WHERE review_id IS NOT NULL;


        PRINT '>> Cleaning & Inserting Into: silver.orders';
        TRUNCATE TABLE silver.orders;
        INSERT INTO silver.orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
        SELECT 
            TRIM(order_id), TRIM(customer_id), LOWER(TRIM(order_status)),
            TRY_CAST(order_purchase_timestamp AS DATETIME2),
            TRY_CAST(order_approved_at AS DATETIME2),
            TRY_CAST(order_delivered_carrier_date AS DATETIME2),
            CASE WHEN TRY_CAST(order_delivered_customer_date AS DATETIME2) >= TRY_CAST(order_purchase_timestamp AS DATETIME2) 
                 THEN TRY_CAST(order_delivered_customer_date AS DATETIME2) ELSE NULL END,
            TRY_CAST(order_estimated_delivery_date AS DATETIME2)
        FROM bronze.orders
        WHERE order_id IS NOT NULL;



        PRINT '>> Cleaning & Inserting Into: silver.products';
        TRUNCATE TABLE silver.products;
        INSERT INTO silver.products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
        SELECT 
            TRIM(p.product_id),
            ISNULL(LOWER(TRIM(t.product_category_name_english)), ISNULL(LOWER(TRIM(p.product_category_name)), 'n/a')),
            ISNULL(TRY_CAST(p.product_name_lenght AS INT), 0),        
            ISNULL(TRY_CAST(p.product_description_lenght AS INT), 0), 
            ISNULL(TRY_CAST(p.product_photos_qty AS INT), 0),
            ISNULL(TRY_CAST(p.product_weight_g AS INT), 0),
            ISNULL(TRY_CAST(p.product_length_cm AS INT), 0),
            ISNULL(TRY_CAST(p.product_height_cm AS INT), 0),
            ISNULL(TRY_CAST(p.product_width_cm AS INT), 0)
        FROM bronze.products p
        LEFT JOIN bronze.category_translation t 
            ON p.product_category_name = t.product_category_name;



        PRINT '>> Cleaning & Inserting Into: silver.sellers';
        TRUNCATE TABLE silver.sellers;
        INSERT INTO silver.sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
        SELECT TRIM(seller_id), TRIM(seller_zip_code_prefix), LOWER(TRIM(seller_city)), UPPER(TRIM(seller_state))
        FROM bronze.sellers
        WHERE seller_id IS NOT NULL;



        PRINT '>> Cleaning & Inserting Into: silver.category_translation';
        TRUNCATE TABLE silver.category_translation;
        INSERT INTO silver.category_translation (product_category_name, product_category_name_english)
        SELECT LOWER(TRIM(product_category_name)), LOWER(TRIM(product_category_name_english))
        FROM bronze.category_translation;

        PRINT 'Silver Layer Quality Checks & Load Completed Successfully!';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED IN SILVER LAYER!';
        PRINT ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END;
GO


EXEC silver.load_silver;