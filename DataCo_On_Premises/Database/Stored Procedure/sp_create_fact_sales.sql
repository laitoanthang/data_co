GO
USE DB_staging
GO 

ALTER PROCEDURE sp_create_fact_sales
AS
BEGIN
BEGIN TRY
	DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco' ,
			@fact_sales NVARCHAR(50) = 'fact_sales',
			@fact_weekly_delivery_performance NVARCHAR(100) = 'fact_weekly_delivery_performance';

	-- insert into orders 
	IF OBJECT_ID('tempDB..#orders') IS NOT NULL 
	BEGIN 
		DROP TABLE #orders 
	END 
	CREATE TABLE #orders(
		order_id VARCHAR(50) NOT NULL, 
		customer_id VARCHAR(50),
		concat_territory VARCHAR(MAX), 
		product_card_id VARCHAR(50),
		concat_store_address VARCHAR(MAX),
		order_date_dateorders INT,
		shipping_date_dateorders INT,
		order_time INT,
		shipping_time INT,
		delivery_status VARCHAR(50),
		type_of_transaction VARCHAR(50),
		delivery_risk VARCHAR(50),
		order_status VARCHAR(50),
		shipping_mode VARCHAR(50),
		sales FLOAT,
		order_item_discount FLOAT,
		order_profit_per_order FLOAT,
		order_item_quantity INT
	
	)
	INSERT INTO #orders (
			order_id,
			customer_id,
			concat_territory,
			product_card_id,
			concat_store_address,
			order_date_dateorders,
			shipping_date_dateorders,
			order_time,
			shipping_time,
			delivery_status,
			type_of_transaction,
			delivery_risk,
			order_status,
			shipping_mode,
			sales,
			order_item_discount,
			order_profit_per_order,
			order_item_quantity
		) 
		SELECT  
		order_id,
		customer_id,
		CONCAT(market, '_', order_region, '_', order_country, '_', order_state, '_', order_city) as concat_territory,
		product_card_id,
		CONCAT(customer_country,'_', customer_state,'_',customer_city,'_', customer_street) as concat_store_address, 
		CONVERT(INT, CONVERT(VARCHAR,CONVERT(DATETIME, order_date_dateorders,101),112)) AS order_date,
		CONVERT(INT, CONVERT(VARCHAR,CONVERT(DATETIME, shipping_date, 101), 112)) as shipping_date,
		DATEPART(HOUR, CONVERT(DATETIME, order_date_dateorders, 101))*100 + DATEPART(MINUTE,CONVERT(DATETIME, order_date_dateorders, 101)) as order_time,
		DATEPART(HOUR, CONVERT(DATETIME, shipping_date, 101))*100 + DATEPART(MINUTE,CONVERT(DATETIME,  shipping_date, 101)) as shipping_time,
		delivery_status,
		type_of_transaction,
		CASE 
		WHEN late_delivery_risk = '0' THEN 'not late'
		WHEN late_delivery_risk = '1' THEN 'late'
		END AS late_delivery_risk,
		order_status,
		shipping_mode,
		sales,
		order_item_discount,
		order_profit_per_order,
		order_item_quantity
		FROM 
		dataco_orders 

		
	IF OBJECT_ID('tempdb..#fact_sales') IS NOT NULL 
	BEGIN 
		DROP TABLE #fact_sales; 
	END 

		
	-- DECLARE @#fact_sales NVARCHAR(50) = 'fact_sales'
	CREATE TABLE #fact_sales(
			order_id VARCHAR(50) NOT NULL,
		    customer_key INT,
			territory_key INT,
			product_key INT,
			store_key INT,
			order_date_dateorders INT,
			shipping_date_dateorders INT,
			order_time INT,
			shipping_time INT,
			delivery_status_key INT,
			transaction_key INT,
			delivery_risk INT,
			order_status_key INT,
			shipping_mode_key INT,
			sales FLOAT,
			order_item_discount FLOAT,
			order_profit_per_order FLOAT,
			order_item_quantity INT
	)	
	
	-- mapping 
	
	DECLARE @insertSQL NVARCHAR(MAX); 
	SET @insertSQL = 'INSERT INTO ' + @destinationDB + '.dbo.' + @fact_sales + 
		' (    order_id,
    customer_key,
    territory_key,
    product_key,
    store_key,
    order_date_dateorders,
    shipping_date_dateorders,
    order_time,
    shipping_time,
    delivery_status_key,
    transaction_key,
    delivery_risk_key,
    order_status_key,
	shipping_mode_key,
    sales,
    order_item_discount,
    order_profit_per_order,
    order_item_quantity) ' + 
		'SELECT 
			o.order_id, 
			dc.customer_key, 
			dt.territory_key, 
			dp.product_key, 
			ds.store_key, 
			o.order_date_dateorders,
			o.shipping_date_dateorders,
			o.order_time, 
			o.shipping_time, 
			dds.delivery_status_key, 
			dtm.transaction_key, 
			ddr.delivery_risk_key, 
			dos.order_status_key, 
			dsm.shipping_mode_key,
			o.sales, 
			o.order_item_discount, 
			o.order_profit_per_order, 
			o.order_item_quantity 
		FROM 
			#orders o 
		JOIN 
			[DW_Dataco].dbo.dim_customer dc ON o.customer_id =  dc.customer_id
		JOIN 
			[DW_Dataco].dbo.dim_territory dt ON o.concat_territory = dt.ter_concat_territory
		JOIN 
			[DW_Dataco].dbo.dim_product dp ON o.product_card_id = dp.product_card_id
		JOIN 
			[DW_Dataco].dbo.dim_store ds ON o.concat_store_address = ds.concat_store_address
		JOIN 
			[DW_Dataco].dbo.dim_delivery_status dds ON o.delivery_status = dds.delivery_status
		JOIN 
			[DW_Dataco].dbo.dim_transaction dtm ON o.type_of_transaction = dtm.type_of_transaction
		JOIN 
			[DW_Dataco].dbo.dim_delivery_risk ddr ON o.delivery_risk = ddr.delivery_risk
		JOIN 
			[DW_Dataco].dbo.dim_order_status dos ON o.order_status = dos.order_status
		JOIN 
			[DW_Dataco].dbo.dim_shipping_mode dsm ON o.shipping_mode = dsm.shipping_mode'

	EXEC sp_executesql @insertSQL



END TRY
BEGIN CATCH
	DECLARE @errormessage NVARCHAR(1000),
			@errorserverity INT, 
			@errorstate INT;
	SELECT @errormessage = ERROR_MESSAGE(),
			@errorserverity = ERROR_SEVERITY(),
			@errorstate = ERROR_STATE();

	RAISERROR (@errormessage, @errorserverity, @errorstate)
END CATCH
END
