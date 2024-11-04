USE dataco_staging;
GO

CREATE PROCEDURE sp_create_dim_time
AS 
BEGIN
    BEGIN TRY
        DECLARE @destinationDB NVARCHAR(50) = 'dataco_wh',
                @table_name NVARCHAR(50) = 'dim_time';

        IF OBJECT_ID('tempdb..#dim_time') IS NOT NULL
        BEGIN 
            DROP TABLE #dim_time;
        END 

        CREATE TABLE #dim_time(
            time_key INT PRIMARY KEY,
            time TIME NOT NULL,
            hour INT NOT NULL,
            minutes INT NOT NULL,
            block INT NOT NULL
        );

        DECLARE @current_time TIME = '00:00',
                @time_key INT,
                @hour INT,
                @minutes INT,
                @block INT;

        WHILE @current_time <= '23:59'
        BEGIN
            SET @hour = DATEPART(HOUR, @current_time);
            SET @minutes = DATEPART(MINUTE, @current_time);
            SET @time_key = @hour * 100 + @minutes;
            SET @block = @hour * 4 + (@minutes / 16) + 1;

            -- Insert into dim_time table
            INSERT INTO #dim_time (
                time_key,
                time,
                hour,
                minutes,
                block
            )
            VALUES (
                @time_key,
                @current_time,		
                @hour,
                @minutes,
                @block
            );

            -- Move to the next minute
            IF @current_time = '23:59'
                BREAK;
            ELSE
                SET @current_time = DATEADD(MINUTE, 1, @current_time);
        END

        DECLARE @insertSQL NVARCHAR(MAX);
        SET @insertSQL = 'INSERT INTO [' + @destinationDB + '].dbo.' + @table_name + 
                         ' (time_key, time, hour, minutes, block) ' + 
                         'SELECT time_key, time, hour, minutes, block FROM #dim_time';

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
END;
GO
