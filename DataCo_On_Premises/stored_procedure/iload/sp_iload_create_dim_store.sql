GO
USE DB_staging
GO
ALTER PROCEDURE sp_iload_create_dim_store
AS
BEGIN
DECLARE @sourceDB NVARCHAR(50) = 'DB_staging', 
		@destinationDB NVARCHAR(50) = 'DW_Dataco',
		@table_name NVARCHAR(50) = 'dim_store';
BEGIN
	BEGIN TRY
	-- code tao bang bang procedure
	-- dim_store
	IF OBJECT_ID('tempDB..#dim_store') IS NOT NULL

		BEGIN
			DROP TABLE #dim_store
		END

		create table #dim_store(
			store_key INT PRIMARY KEY, 
			concat_store_address VARCHAR(MAX), 
			store_country VARCHAR(50),
			customer_state VARCHAR(50),
			store_city VARCHAR(50),
			store_street VARCHAR(100)
			)

	-- get max value 
	DECLARE @max_store INT;
	SELECT @max_store = MAX(store_key) FROM DW_Dataco.dbo.dim_store

	INSERT INTO #dim_store(store_key, concat_store_address,store_country,customer_state, store_city, store_street)
	SELECT 
	@max_store + ROW_NUMBER() OVER (ORDER BY customer_country),
	CONCAT(customer_country,'_', customer_state,'_',customer_city,'_', customer_street) as ter_concat_store_address
	,customer_country, 
	customer_state, 
	customer_city, 
	customer_street 
	FROM dataco_orders
	WHERE CONCAT(customer_country,'_', customer_state,'_',customer_city,'_', customer_street) NOT IN (
	SELECT concat_store_address FROM DW_Dataco.dbo.dim_store)
	GROUP BY customer_country, customer_state, customer_city, customer_street


	DECLARE @insertSQL NVARCHAR(MAX);
	SET @insertSQL = 'INSERT INTO [' + @destinationDB +'].dbo.' + @table_name + 
	'(store_key, concat_store_address, store_country, store_city,store_street)' + 
	'SELECT store_key, concat_store_address, store_country, store_city,store_street FROM #dim_store';

	EXEC sp_executesql @insertSQL;

	-- print so dong da insert 
	DECLARE @insertedrows INT;
	SET @insertedrows = @@ROWCOUNT;
	PRINT 'Number of row inserted: ' + CAST(@insertedrows as VARCHAR(10));
	
	SELECT TOP(1000) * FROM #dim_store
	ORDER BY store_key
END TRY
BEGIN CATCH 
	DECLARE @errormessage NVARCHAR(1000);
	DECLARE @errorserverity INT;
	DECLARE @errorstate INT;
		SELECT 
			@errormessage = ERROR_MESSAGE(),
			@errorserverity = ERROR_SEVERITY(),
			@errorstate = ERROR_STATE();

		RAISERROR(@errormessage , @errorserverity, @errorstate);
END CATCH
END
END
GO