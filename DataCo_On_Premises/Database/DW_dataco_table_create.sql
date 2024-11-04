GO
USE DW_Dataco
GO

-- CREATE DATABASE DW_Dataco
/*
USE master
DROP DATABASE DW_Dataco
*/
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_fullname VARCHAR(100),
    customer_segment VARCHAR(50),
    start_date DATE,
    end_date DATE,
    is_valid TINYINT
);

CREATE TABLE dim_store (
    store_key INT PRIMARY KEY,
    concat_store_address VARCHAR(MAX),
    store_country VARCHAR(50),
    store_city VARCHAR(50),
    store_street VARCHAR(100)
);

CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_card_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(100),
    product_price FLOAT,
    product_status VARCHAR(50),
    category_key INT,
    start_date DATE,
    end_date DATE,
    is_valid TINYINT
);

CREATE TABLE category (
    category_key INT PRIMARY KEY,
    category_id VARCHAR(50),
    category_name VARCHAR(100),
    department_key INT,
    start_date DATE,
    end_date DATE,
    is_valid TINYINT
);

CREATE TABLE department (
    department_key INT PRIMARY KEY,
    department_id VARCHAR(50),
    department_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    is_valid TINYINT
);

CREATE TABLE dim_shipping_mode (
    shipping_mode_key INT PRIMARY KEY,
    shipping_mode VARCHAR(50)
);

CREATE TABLE dim_transaction (
    transaction_key INT PRIMARY KEY,
    type_of_transaction VARCHAR(50)
);

CREATE TABLE dim_delivery_status (
    delivery_status_key INT PRIMARY KEY,
    delivery_status VARCHAR(50)
);

CREATE TABLE dim_order_status (
    order_status_key INT PRIMARY KEY,
    order_status VARCHAR(50)
);



CREATE TABLE dim_territory (
    territory_key INT PRIMARY KEY,
    ter_concat_territory VARCHAR(MAX),
    market VARCHAR(50),
    order_region VARCHAR(50),
    order_country VARCHAR(100),
	order_state VARCHAR(100),
    order_city VARCHAR(100)
);



CREATE TABLE dim_delivery_risk (
    delivery_risk_key INT PRIMARY KEY,
    delivery_risk VARCHAR(50)
);

CREATE TABLE DW_dataco.dbo.dim_date (
    date_key INT PRIMARY KEY,
	date date,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_of_week VARCHAR(20),
    week_of_year TINYINT
);

CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,
	time TIME,
    hour TINYINT,
    minutes TINYINT,
    block INT
);




