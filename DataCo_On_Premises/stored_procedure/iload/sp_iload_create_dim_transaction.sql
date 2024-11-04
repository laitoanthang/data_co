GO 
USE DB_staging 
GO 

ALTER PROCEDURE sp_iload_create_dim_transaction
AS 
BEGIN
BEGIN TRY 
DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco',
		@table_name NVARCHAR(50) = 'dim_transaction'
	IF OBJECT_ID('tempDB..#dim_transaction') IS NULL
		BEGIN 
			CREATE TABLE #dim_transaction(
				transaction_key INT PRIMARY KEY,
				type_of_transaction VARCHAR(100)
				
				
				)
		END
	DECLARE @max_transaction_key INT;
	SELECT @max_transaction_key = MAX(transaction_key) FROM DW_Dataco.dbo.dim_transaction
	INSERT INTO #dim_transaction(transaction_key,type_of_transaction) 
	SELECT 
		@max_transaction_key + ROW_NUMBER() OVER(ORDER BY type_of_transaction) AS transaction_key,
		type_of_transaction
	FROM
	(
	SELECT type_of_transaction FROM dataco_orders
	EXCEPT 
	SELECT  type_of_transaction FROM DW_Dataco.dbo.dim_transaction

	) AS new_transaction


	-- insert vao datawarehouse 
	DECLARE @insertSQL NVARCHAR(MAX);
	SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
	' (transaction_key, type_of_transaction)' + 
	'SELECT transaction_key, type_of_transaction FROM #dim_transaction' ; 

	EXEC sp_executesql @insertSQL;
END TRY
	BEGIN CATCH 

		DECLARE @errormessage NVARCHAR(1000) ; 
		DECLARE @errorserverity INT;
		DECLARE @errorstate INT; 

		SELECT 
			@errormessage = ERROR_MESSAGE(),
			@errorserverity  = ERROR_SEVERITY(),
			@errorstate  = ERROR_STATE();
		RAISERROR(@errormessage,@errorserverity,@errorstate)

	END CATCH 
END 
GO
