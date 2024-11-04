GO
USE DB_staging
GO

IF NOT EXISTS(SELECT * FROM information_schema.tables WHERE table_name = 'dataco_orders')
BEGIN
    CREATE TABLE dataco_orders(
        type_of_transaction VARCHAR(50), 
        days_for_shipping_real INT, 
        days_for_shipment_scheduled INT, 
        benefit_per_order FLOAT, 
        sales_per_customer FLOAT, 
        delivery_status VARCHAR(50),
        late_delivery_risk INT, 
        category_id VARCHAR(50), 
        category_name VARCHAR(100),
        customer_city VARCHAR(100), 
        customer_country VARCHAR(100), 
        customer_email VARCHAR(100), 
        customer_fname VARCHAR(50), 
        customer_id VARCHAR(50),
        customer_lname VARCHAR(50), 
        customer_password VARCHAR(100),
        customer_segment VARCHAR(50), 
        customer_state VARCHAR(MAX), 
        customer_street VARCHAR(MAX), 
        customer_zipcode VARCHAR(20), 
        department_id VARCHAR(50), 
        department_name VARCHAR(50),
        latitude FLOAT, 
        longitude FLOAT,
        market VARCHAR(50), 
        order_city VARCHAR(100), 
        order_country VARCHAR(100), 
        order_customer_id VARCHAR(50), 
        order_date_dateorders VARCHAR(200), -- 02/03/2017 6:59 MM/dd/yyyy
 
        order_id VARCHAR(50) NOT NULL , 
        order_item_cardprod_id VARCHAR(50), 
        order_item_discount FLOAT, 
        order_item_discount_rate FLOAT, 
        order_item_id VARCHAR(50), 
        order_item_product_price FLOAT, 
        order_item_profit_ratio FLOAT, 
        order_item_quantity INT, 
        sales FLOAT, 
        order_item_total FLOAT, 
        order_profit_per_order FLOAT, 
        order_region VARCHAR(50), 
        order_state VARCHAR(50), 
        order_status VARCHAR(50), 
        order_zipcode VARCHAR(20), 
        product_card_id VARCHAR(50) NOT NULL, 
        product_category_id VARCHAR(50), 
        product_description VARCHAR(MAX), 
        product_image VARCHAR(MAX), 
        product_name VARCHAR(100), 
        product_price FLOAT, 
        product_status VARCHAR(50), 
        shipping_date VARCHAR(200), 
        shipping_mode VARCHAR(50)
    )
END

SET DATEFORMAT mdy



SELECT * FROM dataco_orders WHERE order_date_dateorders LIKE '%0:00%'
--DELETE FROM dataco_orders