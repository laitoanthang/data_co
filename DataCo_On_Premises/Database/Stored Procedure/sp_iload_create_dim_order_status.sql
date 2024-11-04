GO
USE DB_staging 
GO

CREATE PROCEDURE sp_iload_create_dim_order_status
AS
BEGIN
DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco',
		@table_name NVARCHAR(50)  = 'dim_order_status';
BEGIN TRY
		-- tao bang tam
		IF OBJECT_ID('tempDB..#dim_order_status') IS NULL
			BEGIN 
				CREATE TABLE #dim_order_status(
					order_status_key INT PRIMARY KEY,
					order_status VARCHAR(50)
				)

			END
		DECLARE @max_order_status_key INT;
		SELECT @max_order_status_key = MAX(order_status_key) FROM DW_Dataco.dbo.dim_order_status
		-- insert du lieu vao bang tam 
		INSERT INTO #dim_order_status(order_status_key, order_status)
		SELECT 
			@max_order_status_key + ROW_NUMBER() OVER(ORDER BY order_status) order_status_key,
			order_status
		FROM
		(
		SELECT order_status
		FROM dataco_orders
		EXCEPT
		SELECT order_status 
		FROM DW_Dataco.dbo.dim_order_status
		) AS new_order_status
		-- insert du lieu vao data warehouse
		DECLARE @insertSQL NVARCHAR(MAX);
		SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name +
		' (order_status_key, order_status)' + 
		'SELECT order_status_key, order_status FROM #dim_order_status';

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

