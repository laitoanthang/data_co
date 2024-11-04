USE DB_staging
GO

ALTER PROCEDURE sp_iload_create_dim_product
AS 
BEGIN
    DECLARE @sourceDB NVARCHAR(50) = 'DB_staging', 
            @destinationDB NVARCHAR(50) = 'DW_Dataco',
            @table_name NVARCHAR(50) = 'dim_product';

    BEGIN TRY
        -- Create the temporary table if it does not exist
        IF OBJECT_ID('tempdb..#dim_product') IS NOT NULL

			BEGIN
				DROP TABLE #dim_product
			END
		CREATE TABLE #dim_product (
			product_key INT PRIMARY KEY, 
			product_card_id VARCHAR(50) NOT NULL,
			product_name VARCHAR(100),
			product_price FLOAT, 
			product_status VARCHAR(50),
			category_key INT ,
			start_date DATE, 
			end_date DATE, 
			is_valid TINYINT
		);
		
		DECLARE @max_product_key INT;
		SELECT  @max_product_key = MAX(product_key) FROM DW_dataco.dbo.dim_product



        -- Insert data into the temporary table
        INSERT INTO #dim_product (product_key, product_card_id, product_name, product_price, product_status, category_key, start_date, end_date, is_valid)
		SELECT 
			@max_product_key + ROW_NUMBER() OVER(ORDER BY product_card_id),
			product_card_id,
			product_name,
			product_price,
			product_status,
			category_key,
			CAST(GETDATE() AS DATE) as start_date, 
			'9999-12-31' as end_date,
			1 as is_valid
			FROM
			(SELECT product_card_id, product_name, product_price, product_status, category_key 
			FROM dataco_orders o JOIN DW_Dataco.dbo.category c ON 
			o.category_id = c.category_id 
			WHERE is_valid = 1 
			EXCEPT 

			SELECT product_card_id, product_name, product_price, product_status, category_key
			FROM DW_Dataco.dbo.dim_product 
			WHERE is_valid = 1 

			) as new_product

		-- update values to old 

		UPDATE p
		SET is_valid = 0,
			end_date = CONVERT(VARCHAR, GETDATE(), 23)
		FROM DW_Dataco.dbo.dim_product p
		WHERE product_card_id IN (SELECT product_card_id FROM #dim_product) AND is_valid = 1;


		--SELECT * FROM DW_Dataco.dbo.dim_product p
		--WHERE product_card_id IN (SELECT product_card_id FROM #dim_product) AND is_valid = 1;
		-- SELECT * FROM #dim_product

        -- Dynamic SQL to insert data into the destination database table
        DECLARE @insertSQL NVARCHAR(MAX);
        SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
		
						' (product_key, product_card_id, product_name, product_price, product_status, category_key, start_date, end_date, is_valid) ' +
                         'SELECT product_key, product_card_id, product_name, product_price, product_status, category_key, start_date, end_date, is_valid FROM #dim_product';

        EXEC sp_executesql @insertSQL;

        -- Print the number of rows inserted
        DECLARE @insertedrows INT;
        SET @insertedrows = @@ROWCOUNT;
        PRINT 'Number of rows inserted: ' + CAST(@insertedrows AS VARCHAR(10));

        -- Select top 1000 rows from the temporary table for verification

    END TRY
    BEGIN CATCH
        DECLARE @errormessage NVARCHAR(4000);
        DECLARE @errorseverity INT;
        DECLARE @errorstate INT;

        SELECT 
            @errormessage = ERROR_MESSAGE(),
            @errorseverity = ERROR_SEVERITY(),
            @errorstate = ERROR_STATE();

        RAISERROR (@errormessage, @errorseverity, @errorstate);
    END CATCH
END
GO
