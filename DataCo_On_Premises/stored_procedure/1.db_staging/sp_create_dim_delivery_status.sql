GO
USE dataco_staging 
GO 

CREATE PROCEDURE sp_create_dim_delivery_status 
AS 
BEGIN
DECLARE @destinationDB NVARCHAR(50) = 'dataco_wh', 
		@table_name NVARCHAR(50) = 'dim_delivery_status'; 

BEGIN TRY
	IF OBJECT_ID('tempDB..#dim_delivery_status') IS NULL
			BEGIN
				CREATE TABLE #dim_delivery_status(
					delivery_status_key INT IDENTITY(1,1), 
					delivery_status VARCHAR(50)
				
				)
			END
		-- insert du lieu vao bang tam
		INSERT INTO #dim_delivery_status 
		SELECT delivery_status FROM 
		dataco_orders 
		GROUP BY delivery_status

		--SELECT * FROM #dim_delivery_status
		-- insert du lieu vao DW
		DECLARE @insertSQL NVARCHAR(MAX);
		SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
		' (delivery_status_key, delivery_status)' +  
		' SELECT delivery_status_key, delivery_status FROM #dim_delivery_status';

		EXEC sp_executesql @insertSQL ; 

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