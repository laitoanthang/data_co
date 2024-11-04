GO
USE DB_staging
GO

CREATE PROCEDURE sp_create_dim_date
AS
BEGIN
DECLARE @destinationDB NVARCHAR(50) = 'DW_Dataco',
		@table_name NVARCHAR(50) = 'dim_date'
BEGIN TRY
		DECLARE @min_date date, @max_date date, @max_dim_date date;

	
		SELECT @max_dim_date = ISNULL(MAX(CONVERT(date, CAST(date_key AS VARCHAR), 112)), '1900-01-01') 
		FROM DW_Dataco.dbo.dim_date;


		SELECT @min_date = MIN(CONVERT(date, order_date_dateorders, 101)) 
		FROM dataco_orders
		WHERE CONVERT(date, order_date_dateorders, 101) > @max_dim_date;

		
		SELECT @max_date = MAX(CONVERT(date, shipping_date, 101)) 
		FROM dataco_orders
		WHERE CONVERT(date, order_date_dateorders, 101) > @max_dim_date;

        -- If the dim_date table already exists, drop it
        IF OBJECT_ID('tempDB..#dim_date') IS NOT NULL
        BEGIN
            DROP TABLE #dim_date;
        END
        
        -- Create the dim_date table
        CREATE TABLE #dim_date (
            date_key INT PRIMARY KEY,
			date date,
            year INT NOT NULL,
            quarter INT NOT NULL,
            month INT NOT NULL,
            day INT NOT NULL,
            day_of_week NVARCHAR(10) NOT NULL,
            week_of_year INT NOT NULL
        );
		
		DECLARE @current_date date = @min_date;

		WHILE @current_date	 <= @max_date	
			BEGIN
			INSERT INTO #dim_date (
                date_key,
				date,
                year,
                quarter,
                month,
                day,
                day_of_week,
                week_of_year
            )
            VALUES(
				CONVERT(INT,CONVERT	(VARCHAR, @current_date,112)),
				CAST(@current_date AS date),
				YEAR(@current_date),
				DATEPART(QUARTER, @current_date),
				MONTH(@current_date),
				DAY(@current_date),
				DATENAME(WEEKDAY, @current_date),
                DATEPART(WEEK, @current_date)
			
			);	
			SET @current_date = DATEADD(DAY, 1, @current_date);	

		END

	
		DECLARE @insertSQL NVARCHAR(MAX);
		SET @insertSQL = 'INSERT INTO ['  + @destinationDB + '].dbo.' + @table_name + 
		' (date_key,date, year, quarter, month, day, day_of_week, week_of_year)' + 
		' SELECT date_key,date, year, quarter, month, day, day_of_week, week_of_year FROM #dim_date';
		
		EXEC sp_executesql @insertSQL;
										
END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO
