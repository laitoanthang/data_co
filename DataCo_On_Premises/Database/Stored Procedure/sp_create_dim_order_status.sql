GO
USE DB_staging 
GO

CREATE PROCEDURE sp_create_dim_order_status
AS
BEGIN
DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco',
		@table_name NVARCHAR(50)  = 'dim_order_status';
BEGIN TRY
		-- tao bang tam
		IF OBJECT_ID('tempDB..#dim_order_status') IS NULL
			BEGIN 
				CREATE TABLE #dim_order_status(
					order_status_key INT IDENTITY(1,1),
					order_status VARCHAR(50)
				)

			END
		-- insert du lieu vao bang tam 
		INSERT INTO #dim_order_status(order_status)
		SELECT order_status
		FROM dataco_orders
		GROUP BY order_status 
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

