GO 
USE  DB_staging 
GO

CREATE PROCEDURE sp_iload_create_department
AS 
BEGIN
	DECLARE @sourceDB NVARCHAR(50) = 'DB_staging',
            @destinationDB NVARCHAR(50) = 'DW_Dataco',
            @table_name NVARCHAR(50) = 'department	';
BEGIN TRY

	--code tao bang tu procedure
	-- department bang mock up dim_product
	IF OBJECT_ID('tempDB..#department') IS NOT NULL 
		BEGIN 
			DROP TABLE #department
		END

	CREATE TABLE #department(
		department_key INT,
		department_id VARCHAR(50), 
		department_name VARCHAR(50),
		start_date date, 
		end_date date , 
		is_valid tinyint
	)
	DECLARE @max_key INT;
	SELECT @max_key = MAX(department_key) FROM DW_Dataco.dbo.department
	INSERT INTO #department(department_key, department_id, department_name,start_date,end_date,is_valid)
	SELECT 
		@max_key + ROW_NUMBER() OVER (ORDER BY t.department_id) AS department_key,
		t.department_id, 
		t.department_name,
		CAST(GETDATE() AS DATE) AS start_date,
		'9999-12-31' AS end_date,
		1 AS is_valid
	FROM (
		SELECT department_id, department_name
		FROM dataco_orders
		EXCEPT 
		SELECT department_id, department_name 
		FROM DW_Dataco.dbo.department
		WHERE is_valid = 1
	) t;

	
	

		
	 --SELECT * FROM #department	
	 --SELECT * FROM DW_dataco.dbo.department
		-- update values to old 

		UPDATE d
		SET is_valid = 0,
			end_date = CONVERT(VARCHAR, GETDATE(), 23)
		FROM DW_Dataco.dbo.department d
		WHERE department_id IN (SELECT department_id FROM #department) AND is_valid = 1;

		-- update values in category
		UPDATE c
		SET is_valid = 0,
			end_date = CONVERT(VARCHAR, GETDATE(), 23)
		FROM DW_Dataco.dbo.category c JOIN DW_Dataco.dbo.department d 
		ON c.department_key = d.department_key
		WHERE d.is_valid = 0 AND department_id IN (
		SELECT department_id 
		FROM #department)

	

		-- SELECT * FROM #Department
		--UPDATE d
		--SET is_valid = 1, 
		--end_date = '9999-12-31'
		--FROM  DW_dataco.dbo.department d
		--WHERE department_id = '12'
		--SELECT * FROM Dw_dataco.dbo.department

		-- insert vao data warehouse
		DECLARE @insertSQL NVARCHAR(MAX);
        SET @InsertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
                         'SELECT department_key,department_id, department_name, start_date, end_date, is_valid FROM #department';

        EXEC sp_executesql @insertSQL;

		-- print ra so dong da insert
		DECLARE @insertedrows INT;
		SET @insertedrows  = @@ROWCOUNT
		PRINT 'Number of row inserted: ' + CAST(@insertedrows as VARCHAR(10))
			-- Step 1: Calculate the maximum category key
		DECLARE @max_category_key INT;
		SELECT @max_category_key = ISNULL(MAX(category_key), 0) FROM DW_Dataco.dbo.category;

		-- Step 2: Select the relevant data from dataco_orders and #department
		-- and generate new category_key values, set start_date, end_date, and is_valid

		-- INSERT new values in to category

		INSERT INTO DW_Dataco.dbo.category (category_key, category_id, category_name, department_key, start_date, end_date, is_valid)
		SELECT 
			@max_category_key + ROW_NUMBER() OVER (ORDER BY o.category_id) AS category_key,
			o.category_id, 
			o.category_name,
			d.department_key,
			CAST(GETDATE() AS DATE) AS start_date,
			'9999-12-31' AS end_date,
			1 AS is_valid
		FROM dataco_orders o
		JOIN #department d ON o.department_id = d.department_id
		WHERE d.department_id IN (
			SELECT department_id 
			FROM DW_Dataco.dbo.department 
			WHERE is_valid = 0
		)
		GROUP BY d.department_id, d.department_name, o.category_id, o.category_name, d.department_key;
		


		
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




		