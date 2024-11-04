USE DB_staging 
GO

CREATE PROCEDURE sp_create_dim_territory 
AS
BEGIN 
    DECLARE @sourceDB NVARCHAR(50) = 'DB_staging',
            @destinationDB NVARCHAR(50) = 'DW_Dataco',
            @table_name NVARCHAR(50) = 'dim_territory';

    BEGIN TRY 
        -- Check if the temporary table exists and create if it does not
        IF OBJECT_ID('tempdb..#dim_territory') IS NULL
        BEGIN 
            CREATE TABLE #dim_territory (
                territory_key INT IDENTITY(1,1), 
                ter_concat_territory VARCHAR(MAX),
                market VARCHAR(50),
                order_region VARCHAR(50),
                order_country VARCHAR(100),
                order_state VARCHAR(50),
                order_city VARCHAR(100)
            );
        END

        -- Insert data into the temporary table
        INSERT INTO #dim_territory (ter_concat_territory, market, order_region, order_country, order_state, order_city)
        SELECT 
            CONCAT(market, '_', order_region, '_', order_country, '_', order_state, '_', order_city) AS ter_concat_territory,
            market, 
            order_region,
            order_country,
            order_state, 
            order_city
        FROM dataco_orders
        GROUP BY 	
            market, 
            order_region,
            order_country,
            order_state, 
            order_city;

        -- Dynamic SQL to insert data into the destination database table
        DECLARE @insertSQL NVARCHAR(MAX);
        SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
                         ' (territory_key, ter_concat_territory, market, order_region, order_country, order_state, order_city)' +
                         ' SELECT territory_key, ter_concat_territory, market, order_region, order_country, order_state, order_city FROM #dim_territory';
        
        EXEC sp_executesql @insertSQL;
        
        -- Print the number of rows inserted
        DECLARE @insertedrows INT; 
        SET @insertedrows = @@ROWCOUNT;
        PRINT 'Number of rows inserted: ' + CAST(@insertedrows AS VARCHAR(10));

        -- Select top 1000 rows from the temporary table for verification
        SELECT TOP (1000) * 
        FROM #dim_territory
        ORDER BY territory_key ASC;

    END TRY
    BEGIN CATCH
        DECLARE @errormessage NVARCHAR(4000);
        DECLARE @errorseverity INT; 
        DECLARE @errorstate INT;
        
        SELECT 
            @errormessage = ERROR_MESSAGE(),
            @errorseverity = ERROR_SEVERITY(),
            @errorstate = ERROR_STATE();

        RAISERROR(@errormessage, @errorseverity, @errorstate);
    END CATCH 
END 
GO
