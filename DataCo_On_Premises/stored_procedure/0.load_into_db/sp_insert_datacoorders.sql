GO
USE dataco_staging
GO


IF OBJECT_ID('sp_insert_datacoorders', 'P') IS NOT NULL 
    DROP PROCEDURE sp_insert_datacoorders
GO

CREATE PROCEDURE sp_insert_datacoorders
    @type_of_transaction VARCHAR(50),
    @days_for_shipping_real INT,
    @days_for_shipment_scheduled INT,
    @benefit_per_order FLOAT,
    @sales_per_customer FLOAT,
    @delivery_status VARCHAR(50),
    @late_delivery_risk INT,
    @category_id VARCHAR(50),
    @category_name VARCHAR(100),
    @customer_city VARCHAR(100),
    @customer_country VARCHAR(100),
    @customer_email VARCHAR(100),
    @customer_fname VARCHAR(50),
    @customer_id VARCHAR(50),
    @customer_lname VARCHAR(50),
    @customer_password VARCHAR(100),
    @customer_segment VARCHAR(50),
    @customer_state VARCHAR(MAX),
    @customer_street VARCHAR(MAX),
    @customer_zipcode VARCHAR(20),
    @department_id VARCHAR(50),
    @department_name VARCHAR(50),
    @latitude FLOAT,
    @longitude FLOAT,
    @market VARCHAR(50),
    @order_city VARCHAR(100),
    @order_country VARCHAR(100),
    @order_customer_id VARCHAR(50),
    @order_date_dateorders DATETIME,
    @order_id VARCHAR(50),
    @order_item_cardprod_id VARCHAR(50),
    @order_item_discount FLOAT,
    @order_item_discount_rate FLOAT,
    @order_item_id VARCHAR(50),
    @order_item_product_price FLOAT,
    @order_item_profit_ratio FLOAT,
    @order_item_quantity INT,
    @sales FLOAT,
    @order_item_total FLOAT,
    @order_profit_per_order FLOAT,
    @order_region VARCHAR(50),
    @order_state VARCHAR(50),
    @order_status VARCHAR(50),
    @order_zipcode VARCHAR(20),
    @product_card_id VARCHAR(50),
    @product_category_id VARCHAR(50),
    @product_description VARCHAR(MAX),
    @product_image VARCHAR(MAX),
    @product_name VARCHAR(100),
    @product_price FLOAT,
    @product_status VARCHAR(50),
    @shipping_date DATETIME,
    @shipping_mode VARCHAR(50)
AS
BEGIN
    INSERT INTO dataco_orders (
        type_of_transaction,
        days_for_shipping_real,
        days_for_shipment_scheduled,
        benefit_per_order,
        sales_per_customer,
        delivery_status,
        late_delivery_risk,
        category_id,
        category_name,
        customer_city,
        customer_country,
        customer_email,
        customer_fname,
        customer_id,
        customer_lname,
        customer_password,
        customer_segment,
        customer_state,
        customer_street,
        customer_zipcode,
        department_id,
        department_name,
        latitude,
        longitude,
        market,
        order_city,
        order_country,
        order_customer_id,
        order_date_dateorders,
        order_id,
        order_item_cardprod_id,
        order_item_discount,
        order_item_discount_rate,
        order_item_id,
        order_item_product_price,
        order_item_profit_ratio,
        order_item_quantity,
        sales,
        order_item_total,
        order_profit_per_order,
        order_region,
        order_state,
        order_status,
        order_zipcode,
        product_card_id,
        product_category_id,
        product_description,
        product_image,
        product_name,
        product_price,
        product_status,
        shipping_date,
        shipping_mode
    ) VALUES (
        @type_of_transaction,
        @days_for_shipping_real,
        @days_for_shipment_scheduled,
        @benefit_per_order,
        @sales_per_customer,
        @delivery_status,
        @late_delivery_risk,
        @category_id,
        @category_name,
        @customer_city,
        @customer_country,
        @customer_email,
        @customer_fname,
        @customer_id,
        @customer_lname,
        @customer_password,
        @customer_segment,
        @customer_state,
        @customer_street,
        @customer_zipcode,
        @department_id,
        @department_name,
        @latitude,
        @longitude,
        @market,
        @order_city,
        @order_country,
        @order_customer_id,
        @order_date_dateorders,
        @order_id,
        @order_item_cardprod_id,
        @order_item_discount,
        @order_item_discount_rate,
        @order_item_id,
        @order_item_product_price,
        @order_item_profit_ratio,
        @order_item_quantity,
        @sales,
        @order_item_total,
        @order_profit_per_order,
        @order_region,
        @order_state,
        @order_status,
        @order_zipcode,
        @product_card_id,
        @product_category_id,
        @product_description,
        @product_image,
        @product_name,
        @product_price,
        @product_status,
        @shipping_date,
        @shipping_mode
    )
END
GO


USE dataco_staging;
GO
/* test 
-- Execute the stored procedure sp_insert_datacoorders with the provided data
EXEC sp_insert_datacoorders
    @type_of_transaction = 'DEBIT',
    @days_for_shipping_real = 3,
    @days_for_shipment_scheduled = 4,
    @benefit_per_order = 91.25,
    @sales_per_customer = 314.6400146,
    @delivery_status = 'Advance shipping',
    @late_delivery_risk = 0,
    @category_id = '73',
    @category_name = 'Sporting Goods',
    @customer_city = 'Caguas',
    @customer_country = 'Puerto Rico',
    @customer_email = 'XXXXXXXXX', -- Replace with actual email
    @customer_fname = 'Cally',
    @customer_id = '20755',
    @customer_lname = 'Holloway',
    @customer_password = 'XXXXXXXXX', -- Replace with actual password
    @customer_segment = 'Consumer',
    @customer_state = 'PR',
    @customer_street = '5365 Noble Nectar Island',
    @customer_zipcode = '725',
    @department_id = '2',
    @department_name = 'Fitness',
    @latitude = 18.2514534,
    @longitude = -66.03705597,
    @market = 'Pacific Asia',
    @order_city = 'Bekasi',
    @order_country = 'Indonesia',
    @order_customer_id = '20755',
    @order_date_dateorders = '2018-01-31 22:56:00',
    @order_id = '77202',
    @order_item_cardprod_id = '1360',
    @order_item_discount = 13.10999966,
    @order_item_discount_rate = 0.039999999,
    @order_item_id = '180517',
    @order_item_product_price = 327.75,
    @order_item_profit_ratio = 0.289999992,
    @order_item_quantity = 1,
    @sales = 327.75,
    @order_item_total = 314.6400146,
    @order_profit_per_order = 91.25,
    @order_region = 'Southeast Asia',
    @order_state = 'Java Occidental',
    @order_status = 'COMPLETE',
    @order_zipcode = '', -- Missing value
    @product_card_id = '1360',
    @product_category_id = '73',
    @product_description = '', -- Missing value
    @product_image = 'http://images.acmesports.sports/Smart+watch', -- Assuming this is the correct URL
    @product_name = 'Smart watch',
    @product_price = 327.75,
    @product_status = '0', -- Assuming this is the correct status
    @shipping_date = '2018-02-03 22:56:00',
    @shipping_mode = 'Standard Class';
GO

SELECT * FROM dataco_orders
DELETE FROM dataco_orders WHERE type_of_transaction = 'DEBIT'

*/