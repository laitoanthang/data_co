GO
USE DB_staging 
GO 

ALTER PROCEDURE sp_iload_create_dim_customer
AS 
DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco',
		@table_name NVARCHAR(50) = 'dim_customer';
BEGIN 
BEGIN TRY 
		IF OBJECT_ID('tempDB..#dim_customer') IS NOT NULL
			BEGIN 
				DROP TABLE #dim_customer
			END 

		CREATE TABLE #dim_customer(
			customer_key INT PRIMARY KEY,
			customer_id VARCHAR(50),
			customer_fullname VARCHAR(100),
			customer_segment VARCHAR(50),
			start_date date,
			end_date date,
			is_valid TINYINT

		)

		DECLARE @max_customer_key INT;
		SELECT @max_customer_key = MAX(customer_key) FROM DW_Dataco.dbo.dim_customer
		INSERT INTO #dim_customer(customer_key, customer_id, customer_fullname, customer_segment,start_date,end_date,is_valid)
		SELECT 
		@max_customer_key + ROW_NUMBER() OVER(ORDER BY customer_id),
		customer_id, 
		full_name, 
		customer_segment,
		CAST(GETDATE() AS DATE) as start_date,
		'9999-12-31' AS end_date,
		1 AS is_valid 
		FROM (
		SELECT 
		customer_id,
		CONCAT(customer_fname, ' ', customer_lname) as full_name, 
		customer_segment
		FROM dataco_orders

		EXCEPT 

		SELECT 
		customer_id,
		customer_fullname, 
		customer_segment

		FROM DW_Dataco.dbo.dim_customer
		WHERE is_valid = 1) as new_customer
		-- SELECT * FROM #dim_customer
		-- update old values

		UPDATE DW_Dataco.dbo.dim_customer
		SET end_date = CAST(GETDATE() AS DATE), is_valid = 0 
		WHERE customer_id IN (SELECT customer_id FROM #dim_customer)
		
		
		--SELECT customer_id FROM DW_Dataco.dbo.dim_customer WHERE customer_id = '13649'

		DECLARE @insertSQL NVARCHAR(MAX);
		SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
		' (customer_key, customer_id, customer_fullname, customer_segment,start_date,end_date,is_valid)' +
		'SELECT customer_key, customer_id, customer_fullname, customer_segment,start_date,end_date,is_valid FROM #dim_customer' ;

		EXEC sp_executesql @insertSQL 

		-- Print the number of rows inserted
        DECLARE @insertedrows INT;
        SET @insertedrows = @@ROWCOUNT;
        PRINT 'Number of rows inserted: ' + CAST(@insertedrows AS VARCHAR(10));

		



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