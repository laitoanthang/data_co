USE [dataco_staging]
GO
/****** Object:  StoredProcedure [dbo].[sp_create_category]    Script Date: 05/06/2024 10:33:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_create_category] 
AS 
BEGIN
DECLARE @sourceDB NVARCHAR(50) = 'dataco_staging',
		@destinationDB NVARCHAR(50) = 'dataco_wh',
		@table_name  NVARCHAR(50) = 'category';
BEGIN TRY 
	IF OBJECT_ID('tempDB..#category') IS NULL 
		BEGIN
			CREATE TABLE #category(
					category_key INT IDENTITY(1,1),
					category_id VARCHAR(50), 
					category_name VARCHAR(100),
					department_key INT,
					start_date date ,
					end_date date,
					is_valid TINYINT 
			
			)
			
		END
	INSERT INTO #category(category_id, category_name, department_key,start_date,end_date,is_valid)
	SELECT 
        category_id, 
        category_name, 
        department_key,
        CAST(GETDATE() AS DATE) as start_date,
        '9999-12-31' as end_date ,
	    1 as is_valid 
	FROM dataco_orders o JOIN dataco_wh.dbo.department dp 
	ON o.department_id = dp.department_id
	GROUP BY category_id, category_name, department_key
	ORDER BY category_id, category_name, department_key ASC

	-- insert du lieu vao DW 
	DECLARE @insertSQL NVARCHAR(MAX);
	SET 
        @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
	                ' (category_key, category_id, category_name, department_key,start_date, end_date, is_valid)' + 
	                'SELECT  category_key, category_id, category_name, department_key,start_date, end_date, is_valid FROM #category';

	EXEC sp_executesql @insertSQL;

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
