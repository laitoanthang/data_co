GO
USE DB_Staging
GO

CREATE PROCEDURE sp_create_fact_delivery_perf
AS
BEGIN
    BEGIN TRY
        DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco',
                @fact_weekly_delivery_performance NVARCHAR(100) = 'fact_weekly_delivery_performance';

        -- Insert into orders 
        IF OBJECT_ID('tempdb..#fact_sales') IS NOT NULL 
        BEGIN 
            DROP TABLE #fact_sales;
        END 
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
            delivery_risk_key INT,
            order_status_key INT,
            sales FLOAT,
            order_item_discount FLOAT,
            order_profit_per_order FLOAT,
            order_item_quantity INT
        );  

        INSERT INTO #fact_sales(
            order_id,
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
            sales,
            order_item_discount,
            order_profit_per_order,
            order_item_quantity 
        )
        SELECT    
            order_id,
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
            sales,
            order_item_discount,
            order_profit_per_order,
            order_item_quantity 
        FROM DW_Dataco.dbo.fact_sales;

        -- Create fact table data
        DECLARE @insertSQL NVARCHAR(MAX); 
		SET @insertSQL = '
			WITH cte AS (
				SELECT
					d.year, 
					d.month, 
					o.order_time,
					o.territory_key,
					o.order_date_dateorders,
					SUM(CASE WHEN o.delivery_status_key = 4 THEN 1 ELSE 0 END) AS total_cancellation,
					SUM(CASE WHEN o.delivery_status_key = 2 THEN 1 ELSE 0 END) AS on_time_orders, 
					SUM(CASE WHEN o.delivery_status_key = 1 THEN 1 ELSE 0 END) AS advanced_orders,
					SUM(CASE WHEN o.delivery_status_key = 3 THEN 1 ELSE 0 END) AS late_orders,
					COUNT(o.order_id) AS total_orders
				FROM
					(SELECT order_date_dateorders, order_time, delivery_status_key, order_id, territory_key
					 FROM #fact_sales
					 GROUP BY order_date_dateorders, order_time, delivery_status_key, order_id, territory_key) o
				RIGHT JOIN
					DW_dataco.dbo.dim_date d ON o.order_date_dateorders = d.date_key
				GROUP BY
					o.territory_key, d.year, d.month, o.order_date_dateorders, o.order_time
			)
			INSERT INTO ' + @destinationDB + '.dbo.' + @fact_weekly_delivery_performance + '
			(date_key,
			 time_key,
			 territory_key,
			 total_cancellation,
			 on_time_orders,
			 advanced_orders,
			 late_orders,
			 total_orders)
			SELECT 
				order_date_dateorders AS date_key,
				order_time AS time_key,
				territory_key,
				total_cancellation,
				on_time_orders, 
				advanced_orders,
				late_orders,
				total_orders
			FROM cte 
			WHERE order_date_dateorders IS NOT NULL
			ORDER BY order_date_dateorders ASC';


        -- Execute the dynamic SQL
        EXEC sp_executesql @insertSQL;
    END TRY 
BEGIN CATCH
    DECLARE @errormessage NVARCHAR(1000);
    DECLARE @errorseverity INT;
    DECLARE @errorstate INT; 

    SELECT 
        @errormessage = ERROR_MESSAGE(),
        @errorseverity = ERROR_SEVERITY(),
        @errorstate = ERROR_STATE();

    RAISERROR(@errormessage, @errorseverity, @errorstate);
END CATCH
END;
