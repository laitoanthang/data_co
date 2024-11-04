GO
USE DB_staging 
GO

CREATE PROCEDURE sp_create_dim_delivery_risk
AS
BEGIN
DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco',
		@table_name NVARCHAR(50)  = 'dim_delivery_risk';
BEGIN TRY
		-- tao bang tam
		IF OBJECT_ID('tempDB..#dim_delivery_risk') IS NULL
			BEGIN 
				CREATE TABLE #dim_delivery_risk(
					delivery_risk_key INT IDENTITY(1,1),
					delivery_risk VARCHAR(50)
				)

			END
		-- insert du lieu vao bang tam 
		INSERT INTO #dim_delivery_risk(delivery_risk)
		SELECT	CASE
		WHEN late_delivery_risk = '1' THEN 'late'
		WHEN late_delivery_risk = '0' THEN 'not late'
		END AS late_delivery_risk	
		
		FROM dataco_orders
		GROUP BY late_delivery_risk 
		-- insert du lieu vao data warehouse
		DECLARE @insertSQL NVARCHAR(MAX);
		SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name +
		' (delivery_risk_key, delivery_risk)' + 
		'SELECT delivery_risk_key, delivery_risk FROM #dim_delivery_risk';

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


