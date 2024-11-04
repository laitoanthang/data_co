GO 
USE  dataco_staging 
GO

CREATE PROCEDURE sp_create_department
AS 
BEGIN
	DECLARE @sourceDB NVARCHAR(50) = 'dataco_staging',
            @destinationDB NVARCHAR(50) = 'dataco_wh',
            @table_name NVARCHAR(50) = 'department';
BEGIN TRY

	--code tao bang tu procedure
	-- department bang mock up dim_product
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES  WHERE table_name = '#department')
		BEGIN 
			CREATE TABLE #department(
				department_key INT IDENTITY(1,1),
				department_id VARCHAR(50), 
				department_name VARCHAR(50),
				start_date date, 
				end_date date , 
				is_valid tinyint
			)
		END
		INSERT INTO #department(department_id, department_name,start_date, end_date,is_valid)
		SELECT department_id, 
                department_name,
                CAST(GETDATE() as DATE) as start_date,
                '9999-12-31' as end_date,
                1 as is_valid
		FROM dataco_orders 
		GROUP BY department_id, department_name
		ORDER BY department_id ASC

		-- insert vao data warehouse
		DECLARE @insertSQL NVARCHAR(MAX);
        SET @InsertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
                         'SELECT department_key,department_id, department_name, start_date, end_date, is_valid FROM #department';

        EXEC sp_executesql @insertSQL;

		-- print ra so dong da insert
		DECLARE @insertedrows INT;
		SET @insertedrows  = @@ROWCOUNT
		PRINT 'Number of row inserted: ' + CAST(@insertedrows as VARCHAR(10))
		
		SELECT TOP(1000) * FROM #department
		ORDER BY department_key ASC
END TRY
BEGIN CATCH 
	DECLARE @errormessage NVARCHAR(1000);
	DECLARE @errorserverity INT;
	DECLARE @errorstate INT; 

		SELECT 
			@errormessage = ERROR_MESSAGE(),
			@errorserverity = ERROR_SEVERITY(),
			@errorstate = ERROR_STATE();

		RAISERROR(@errormessage, @errorserverity, @errorstate);
END CATCH
END

GO




		