GO
USE dataco_staging
GO

CREATE PROCEDURE sp_create_fact_monthly_kpi
AS
BEGIN
    BEGIN TRY
        DECLARE @destinationDB NVARCHAR(50) = 'dataco_wh',
                @fact_monthly_kpi NVARCHAR(100) = 'fact_monthly_kpi';

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
		
		DECLARE @insertSQL NVARCHAR(MAX);
		SET @insertSQL = '
			WITH  delivery_status_4_cte AS (
				SELECT 
					dd.year, 
					dd.month, 
					o.store_key, 
					COUNT(delivery_status_key) AS on_time_delivery
				FROM 
					(SELECT 
						order_id, delivery_status_key, order_date_dateorders, store_key 
					FROM 
						#fact_sales 
					GROUP BY 
						order_id, delivery_status_key, order_date_dateorders, store_key
					) AS o
				LEFT JOIN 
					DW_dataco.dbo.dim_date dd 
				ON 
					o.order_date_dateorders = dd.date_key
				WHERE 
					delivery_status_key = 2
				GROUP BY 
					dd.year, dd.month, o.store_key
			),
			total_cte AS (
				SELECT 
					dd.year, 
					dd.month, 
					o.store_key, 
					COUNT(o.delivery_status_key) AS total_delivery_status,
					SUM(o.sales) AS actual_sales,
					SUM(o.order_profit_per_order) AS actual_profit
				FROM 
					(SELECT 
						order_id, 
						delivery_status_key, 
						customer_key, 
						order_date_dateorders, 
						store_key, 
						sales,
						order_profit_per_order
					FROM 
						#fact_sales 
					GROUP BY 
						order_id, 
						delivery_status_key, 
						order_date_dateorders, 
						customer_key, 
						store_key,
						sales,
						order_profit_per_order
					) AS o 
				LEFT JOIN 
					DW_dataco.dbo.dim_date dd ON o.order_date_dateorders = dd.date_key 
				GROUP BY 
					dd.year, dd.month, o.store_key
			),
			total_cus AS (
				SELECT 
					dd.year,
					dd.month,
					store_key,
					COUNT(DISTINCT o.customer_key) AS total_customer
				FROM 
					#fact_sales o
				LEFT JOIN 
					DW_dataco.dbo.dim_date dd ON dd.date_key = o.order_date_dateorders
				GROUP BY 
					dd.year, dd.month, store_key
			),
			cus_cte AS (
				SELECT 
					year, 
					month, 
					store_key, 
					SUM(CASE WHEN num_orders_in_month >= 2 THEN 1 ELSE 0 END) as num_cus_return
				FROM (
					SELECT 
						dd.year,
						dd.month,
						o.customer_key,
						o.store_key,
						COUNT(DISTINCT o.order_id) AS num_orders_in_month
					FROM 
						DW_dataco.dbo.dim_date dd
					LEFT JOIN 
						#fact_sales o ON dd.date_key = o.order_date_dateorders AND o.order_date_dateorders <= (SELECT MAX(order_date_dateorders) FROM #fact_sales)
					GROUP BY 
						dd.year, dd.month, o.customer_key, o.store_key
				) as subquery
				GROUP BY 
					year, month, store_key
			)

			INSERT INTO ' + @destinationDB + '.dbo.' + @fact_monthly_kpi + '
			(date_key, store_key, on_time_orders, total_orders_month, num_cus_return, total_cus_month, actual_sales, actual_profit)
			SELECT 
				FORMAT(EOMONTH(CONVERT(DATE, CONCAT(ds.year, ''-'', ds.month, ''-'', ''01''))), ''yyyyMMdd'') AS date_key,
				ds.store_key, 
				ds.on_time_delivery,
				tc.total_delivery_status, 
				cc.num_cus_return, 
				tcus.total_customer, 
				tc.actual_sales, 
				tc.actual_profit
			FROM 
				delivery_status_4_cte ds 
			JOIN
				total_cte tc ON ds.year = tc.year AND ds.month = tc.month AND ds.store_key = tc.store_key
			JOIN 
				cus_cte cc ON ds.year = cc.year AND ds.month = cc.month AND ds.store_key = cc.store_key
			JOIN 
				total_cus tcus ON tcus.year = cc.year AND tcus.month = cc.month AND tcus.store_key = cc.store_key;
		';


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
