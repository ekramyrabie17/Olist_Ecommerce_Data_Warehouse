CREATE PROCEDURE bronze.load_bronze AS 
BEGIN
    BEGIN TRY
        PRINT 'Loading Bronze Layer (Olist Dataset)';

        TRUNCATE TABLE bronze.customers;
        PRINT '>> Inserting Data Into: bronze.customers';
        BULK INSERT bronze.customers
        FROM 'F:\Olist_DWH\Dataests\olist_customers_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        TRUNCATE TABLE bronze.geolocation;
        PRINT '>> Inserting Data Into: bronze.geolocation';
        BULK INSERT bronze.geolocation
        FROM 'F:\Olist_DWH\Dataests\olist_geolocation_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        TRUNCATE TABLE bronze.order_items;
        PRINT '>> Inserting Data Into: bronze.order_items';
        BULK INSERT bronze.order_items
        FROM 'F:\Olist_DWH\Dataests\olist_order_items_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        TRUNCATE TABLE bronze.order_payments;
        PRINT '>> Inserting Data Into: bronze.order_payments';
        BULK INSERT bronze.order_payments
        FROM 'F:\Olist_DWH\Dataests\olist_order_payments_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        TRUNCATE TABLE bronze.orders;
        PRINT '>> Inserting Data Into: bronze.orders';
        BULK INSERT bronze.orders
        FROM 'F:\Olist_DWH\Dataests\olist_orders_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        TRUNCATE TABLE bronze.products;
        PRINT '>> Inserting Data Into: bronze.products';
        BULK INSERT bronze.products
        FROM 'F:\Olist_DWH\Dataests\olist_products_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        TRUNCATE TABLE bronze.sellers;
        PRINT '>> Inserting Data Into: bronze.sellers';
        BULK INSERT bronze.sellers
        FROM 'F:\Olist_DWH\Dataests\olist_sellers_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        TRUNCATE TABLE bronze.category_translation;
        PRINT '>> Inserting Data Into: bronze.category_translation';
        BULK INSERT bronze.category_translation
        FROM 'F:\Olist_DWH\Dataests\product_category_name_translation.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        TRUNCATE TABLE bronze.order_reviews;
        PRINT '>> Inserting Data Into: bronze.order_reviews';
        BULK INSERT bronze.order_reviews
        FROM 'F:\Olist_DWH\Dataests\olist_order_reviews_dataset.csv'
        WITH (
            FORMAT = 'CSV',
            FIRSTROW = 2,
            FIELDQUOTE = '"',
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0a',
            CODEPAGE = '65001',
            TABLOCK
        );

        PRINT 'Bronze Layer Loaded Successfully!';
    END TRY
    BEGIN CATCH
        PRINT 'ERROR OCCURRED DURING LOAD!';
        PRINT ERROR_MESSAGE();
    END CATCH
END;

EXEC bronze.load_bronze;


