GO
USE DB_staging 
GO

CREATE PROCEDURE sp_iload_create_category 
AS 
BEGIN
DECLARE @sourceDB NVARCHAR(50) = 'DB_staging',
		@destinationDB NVARCHAR(50) = 'DW_dataco',
		@table_name  NVARCHAR(50) = 'category';
BEGIN TRY 
	   -- Drop temporary table if it exists
		IF OBJECT_ID('tempDB..#category') IS NOT NULL 
		BEGIN 
			DROP TABLE #category
		END

		-- Create temporary table
		CREATE TABLE #category(
			category_key INT,
			category_id VARCHAR(50), 
			category_name VARCHAR(100),
			department_key INT,
			start_date DATE,
			end_date DATE,
			is_valid TINYINT
		)

		-- Get max key 
		DECLARE @max_key INT;
		SELECT @max_key = ISNULL(MAX(category_key), 0) FROM DW_Dataco.dbo.category;

		-- Insert new categories
		INSERT INTO #category(category_key, category_id, category_name, department_key, start_date, end_date, is_valid)
		SELECT 
			@max_key + ROW_NUMBER() OVER(ORDER BY category_id),
			category_id,
			category_name,
			department_key,
			CAST(GETDATE() AS DATE) AS start_date,
			'9999-12-31' AS end_date,
			1 AS is_valid
		FROM (
			SELECT category_id, category_name, department_key 
			FROM dataco_orders o JOIN DW_Dataco.dbo.department d 
			ON o.department_id = d.department_id
			WHERE is_valid = 1

			EXCEPT 

			SELECT category_id, category_name, c.department_key 
			FROM DW_Dataco.dbo.category c 
			JOIN DW_Dataco.dbo.department d
			ON c.department_key = d.department_key
			WHERE d.is_valid = 1 AND c.is_valid = 1
		) AS new_categories;

	
		-- update values to old 

		UPDATE c
		SET is_valid = 0,
			end_date = CONVERT(VARCHAR, GETDATE(), 23)
		FROM DW_Dataco.dbo.category c
		WHERE category_id IN (SELECT category_id FROM #category) AND is_valid = 1;

		-- update values in product
		UPDATE p
		SET is_valid = 0,
			end_date = CONVERT(VARCHAR, GETDATE(), 23)
		FROM DW_Dataco.dbo.dim_product p JOIN DW_Dataco.dbo.category c 
		ON c.category_key = p.category_key
		WHERE c.is_valid = 0 AND category_id IN (
		SELECT category_id 
		FROM #category)
	-- SELECT * FROM #category
	-- insert du lieu vao DW 


	DECLARE @insertSQL NVARCHAR(MAX);
	SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
	' (category_key, category_id, category_name, department_key,start_date, end_date, is_valid)' + 
	'SELECT  category_key, category_id, category_name, department_key,start_date, end_date, is_valid FROM #category';

	EXEC sp_executesql @insertSQL;

	--SELECT product_key, product_name, product_price, product_status,category_key,start_date,end_date,is_valid FROM DW_Dataco.dbo.dim_product
	-- insert new value into dim_product
	DECLARE @max_product_key INT;
	SELECT @max_product_key = MAX(product_key) FROM DW_Dataco.dbo.dim_product
	INSERT INTO DW_Dataco.dbo.dim_product(product_key,product_card_id, product_name, product_price, product_status,category_key,start_date,end_date,is_valid)
	SELECT 
		@max_product_key + ROW_NUMBER() OVER( ORDER BY product_card_id),
		o.product_card_id,
		o.product_name, 
		o.product_price,
		o.product_status,
		category_key,
		CAST(GETDATE() AS DATE),
		'9999-12-31' AS end_date,
		1 AS is_valid

	FROM dataco_orders o JOIN #category c 
	ON o.category_id = c.category_id 
	WHERE c.category_id IN (
			SELECT category_id 
			FROM DW_Dataco.dbo.category 
			WHERE is_valid = 0
		)

	GROUP BY o.product_card_id,o.product_name, o.product_price, o.product_status,category_key



	-- in ra du lieu
	DECLARE @insertedrows INT; 
	SET @insertedrows = @@ROWCOUNT
	PRINT 'Number of rows inserted: ' +  CAST(@insertedrows AS VARCHAR(10))

	SELECT TOP(1000) * FROM #category
	ORDER BY category_key ASC
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
