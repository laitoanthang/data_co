GO
USE dataco_staging 
GO 

-- DROP PROCEDURE [dbo].[sp_create_dim_customer]

-- ALTER PROCEDURE sp_create_dim_custommer
CREATE PROCEDURE sp_create_dim_custommer
AS 
DECLARE @destinationDB NVARCHAR(50) = 'dataco_wh',
		@table_name NVARCHAR(50) = 'dim_customer';
BEGIN 
    BEGIN TRY 
		IF OBJECT_ID('tempDB..#dim_customer') IS NULL
			BEGIN 
				CREATE TABLE #dim_customer(
					customer_key INT IDENTITY(1,1) PRIMARY KEY,
					customer_id VARCHAR(50),
					customer_fullname VARCHAR(100),
					customer_segment VARCHAR(50),
					start_date date, 
					end_date date , 
					is_valid tinyint 
				)
			END 
		INSERT INTO #dim_customer(customer_id, customer_fullname, customer_segment,start_date,end_date,is_valid)
		SELECT 
            customer_id, 
            CONCAT(customer_fname, ' ', customer_lname), 
            customer_segment,
            CAST(GETDATE() AS DATE) AS start_date,
            '9999-12-31' AS end_date,
            1 AS is_valid	
		FROM 
            dataco_orders
		GROUP BY 
            customer_id, 
            CONCAT(customer_fname, ' ', customer_lname), 
            customer_segment

		DECLARE @insertSQL NVARCHAR(MAX);
		SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
            ' (customer_key, customer_id, customer_fullname, customer_segment,start_date,end_date,is_valid)' +
		    'SELECT customer_key, customer_id, customer_fullname, customer_segment,start_date,end_date,is_valid FROM #dim_customer' ;

		EXEC sp_executesql @insertSQL 

		-- Print the number of rows inserted
        DECLARE @insertedrows INT;
        SET @insertedrows = @@ROWCOUNT;
        PRINT 'Number of rows inserted: ' + CAST(@insertedrows AS VARCHAR(10));

		SELECT TOP 1000 * FROM #dim_customer
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
GO

