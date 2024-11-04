USE dataco_staging
GO

CREATE PROCEDURE sp_create_dim_product
AS 
BEGIN
    DECLARE @sourceDB NVARCHAR(50) = 'dataco_staging', 
            @destinationDB NVARCHAR(50) = 'dataco_wh',
            @table_name NVARCHAR(50) = 'dim_product';

    BEGIN TRY
        -- Create the temporary table if it does not exist
        IF OBJECT_ID('tempdb..#dim_product') IS NULL
        BEGIN
            CREATE TABLE #dim_product (
                product_key INT IDENTITY(1,1) PRIMARY KEY, 
                product_card_id VARCHAR(50) NOT NULL,
                product_name VARCHAR(100),
                product_price FLOAT, 
                product_status VARCHAR(50),
                category_key INT ,
                start_date DATE, 
                end_date DATE, 
                is_valid TINYINT
            );
        END

        -- Insert data into the temporary table
        INSERT INTO #dim_product (product_card_id, product_name, product_price, product_status, category_key, start_date, end_date, is_valid)
        SELECT
            product_card_id, product_name, product_price, product_status, category_key,
            CAST(GETDATE() AS DATE) AS start_date, '9999-12-31' AS end_date, 1 AS is_valid
        FROM dataco_orders o JOIN DW_Dataco.dbo.category c 
		ON o.category_id  = c.category_id
        GROUP BY product_card_id, product_name, product_price, product_status, category_key
        ORDER BY product_card_id ASC;

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
        SELECT TOP (1000) * 
        FROM #dim_product;

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
