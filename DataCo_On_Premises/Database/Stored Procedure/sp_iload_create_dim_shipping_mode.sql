GO
USE DB_staging 
GO

CREATE PROCEDURE sp_iload_create_dim_shipping_mode 
AS
BEGIN
DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco',
		@table_name NVARCHAR(50)  = 'dim_shipping_mode';
BEGIN TRY
		-- tao bang tam
		IF OBJECT_ID('tempDB..#dim_shipping_mode') IS NULL
			BEGIN 
				CREATE TABLE #dim_shipping_mode(
					shipping_mode_key INT PRIMARY KEY,
					shipping_mode VARCHAR(50)
				)

			END

		DECLARE @max_shipping_mode_key INT;
		SELECT  @max_shipping_mode_key = MAX(shipping_mode_key) FROM DW_Dataco.dbo.dim_shipping_mode
		-- insert du lieu vao bang tam 
		INSERT INTO #dim_shipping_mode(shipping_mode_key, shipping_mode)
		SELECT
			@max_shipping_mode_key + ROW_NUMBER() OVER (ORDER BY shipping_mode) AS shipping_mode_key,
			shipping_mode
		FROM (
			SELECT DISTINCT shipping_mode 
			FROM dataco_orders
			WHERE shipping_mode IS NOT NULL
			EXCEPT
			SELECT shipping_mode 
			FROM DW_Dataco.dbo.dim_shipping_mode
		) AS new_shipping_modes;
		
		-- insert du lieu vao data warehouse
		DECLARE @insertSQL NVARCHAR(MAX);
		SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name +
		' (shipping_mode_key, shipping_mode)' + 
		'SELECT shipping_mode_key, shipping_mode FROM #dim_shipping_mode';

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


