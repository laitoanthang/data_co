USE DB_staging
-- TERRITORY
SELECT    
	order_id,
	market, 
	order_region,
	order_country,
	order_state, 
	order_city
FROM dataco_orders 
WHERE CONVERT(DATETIME, order_date_dateorders, 101) > '10/01/2017' AND order_id = '69703'

-- test
UPDATE dataco_orders 
SET order_city = 'Nuremberg 1'
WHERE order_city = 'Nuremberg' AND order_id = '69703'

-- check 
SELECT COUNT(*) FROM DW_Dataco.dbo.dim_territory

--EXEC sp_iload_create_dim_territory

-- STORE

SELECT 
	order_id,
	CONCAT(customer_country,'_', customer_state,'_',customer_city,'_', customer_street) as ter_concat_store_address
	,customer_country, 
	customer_state, 
	customer_city, 
	customer_street 
FROM dataco_orders
WHERE CONVERT(DATETIME, order_date_dateorders, 101) > '10/01/2017'


UPDATE dataco_orders 
SET customer_street = '6370 Emerald Row 1'
WHERE order_id = '69641'

--EXEC sp_iload_create_dim_store
