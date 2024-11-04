USE DW_Dataco;
GO

CREATE PROCEDURE sp_partition_fact_delivery
AS
BEGIN
DECLARE @start_date INT;
DECLARE @end_date INT;

-- Get the start and end dates
SELECT @start_date = MIN(CONVERT(INT, CONVERT(VARCHAR, CONVERT(DATETIME, order_date_dateorders, 101), 112))) 
FROM DB_staging.dbo.dataco_orders;
SELECT @end_date = MAX(CONVERT(INT, CONVERT(VARCHAR, CONVERT(DATETIME, order_date_dateorders, 101), 112))) 
FROM DB_staging.dbo.dataco_orders;

-- Variables to iterate through the date range
DECLARE @current_date DATE = CONVERT(DATE, CONVERT(VARCHAR, @start_date));
DECLARE @end_date_date DATE = CONVERT(DATE, CONVERT(VARCHAR, @end_date));

-- Temporary table to hold boundary values
CREATE TABLE #PartitionBoundaries (BoundaryDate INT);
-- DROP TABLE #PartitionBoundaries
-- Insert boundary values for each week
WHILE @current_date <= @end_date_date
BEGIN
    INSERT INTO #PartitionBoundaries (BoundaryDate)
    VALUES (CONVERT(INT, FORMAT(@current_date, 'yyyyMMdd')));

    -- Move to the next week
    SET @current_date = DATEADD(WEEK, 1, @current_date);
END

-- Add one more boundary value for the end date
INSERT INTO #PartitionBoundaries (BoundaryDate)
VALUES (CONVERT(INT, FORMAT(DATEADD(WEEK, 1, @end_date_date), 'yyyyMMdd')));

-- Build the partition function and scheme creation scripts
DECLARE @pf_script NVARCHAR(MAX) = N'CREATE PARTITION FUNCTION pf_fact_weekly_delivery_performance (INT) AS RANGE LEFT FOR VALUES (';
DECLARE @ps_script NVARCHAR(MAX) = N'CREATE PARTITION SCHEME ps_fact_weekly_delivery_performance AS PARTITION pf_fact_weekly_delivery_performance TO (';

-- Add boundary values to the partition function script
SELECT @pf_script = @pf_script + CAST(BoundaryDate AS NVARCHAR) + N','
FROM #PartitionBoundaries
ORDER BY BoundaryDate;

-- Remove the trailing comma and close the partition function script
SET @pf_script = LEFT(@pf_script, LEN(@pf_script) - 1) + N');';

-- Add filegroups to the partition scheme script
SELECT @ps_script = @ps_script + N'[PRIMARY],' + N'[PRIMARY],'
FROM #PartitionBoundaries;

-- Remove the trailing comma and close the partition scheme script
SET @ps_script = LEFT(@ps_script, LEN(@ps_script) - 1) + N');';

-- Execute the partition function and scheme creation scripts
EXEC sp_executesql @pf_script;
EXEC sp_executesql @ps_script;

-- Drop the temporary table
DROP TABLE #PartitionBoundaries;

-- Create the partitioned table
CREATE TABLE fact_weekly_delivery_performance (
    date_key INT,
    time_key INT,
    territory_key INT,
    total_cancellation INT,
    on_time_orders INT,
    advanced_orders INT,
	late_orders INT,
	total_orders INT

)
ON ps_fact_weekly_delivery_performance(date_key); -- Use the partition scheme

END
--DROP TABLE fact_weekly_delivery_performance

