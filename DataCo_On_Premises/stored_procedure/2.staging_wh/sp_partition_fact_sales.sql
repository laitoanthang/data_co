GO
USE dataco_wh
GO

CREATE PROCEDURE sp_partition_fact_sales
AS 
BEGIN
    DECLARE @start_date INT;
    DECLARE @end_date INT;

    -- Get the start and end dates
    SELECT @start_date = MIN(CONVERT(INT, CONVERT(VARCHAR,CONVERT(DATETIME, order_date_dateorders,101),112))) FROM dataco_staging.dbo.dataco_orders;
    SELECT @end_date = MAX(CONVERT(INT, CONVERT(VARCHAR,CONVERT(DATETIME, order_date_dateorders,101),112))) FROM dataco_staging.dbo.dataco_orders;

    -- Variables to iterate through the date range
    DECLARE @current_date DATE = CONVERT(DATE, CONVERT(VARCHAR, @start_date));
    DECLARE @end_date_date DATE = CONVERT(DATE, CONVERT(VARCHAR, @end_date));

    -- Temporary table to hold boundary values
    CREATE TABLE #PartitionBoundaries (BoundaryDate INT);

    -- Insert boundary values for each month
    WHILE @current_date <= @end_date_date
    BEGIN
        INSERT INTO #PartitionBoundaries (BoundaryDate)
        VALUES (CONVERT(INT, FORMAT(@current_date, 'yyyyMMdd')));

        -- Move to the next month
        SET @current_date = DATEADD(MONTH, 1, @current_date);
    END

    -- Add one more boundary value for the end date
    INSERT INTO #PartitionBoundaries (BoundaryDate)
    VALUES (CONVERT(INT, FORMAT(DATEADD(MONTH, 1, @end_date_date), 'yyyyMMdd')));

    -- Build the partition function and scheme creation scripts
    DECLARE @pf_script NVARCHAR(MAX) = N'CREATE PARTITION FUNCTION pf_fact_sales (INT) AS RANGE LEFT FOR VALUES (';
    DECLARE @ps_script NVARCHAR(MAX) = N'CREATE PARTITION SCHEME ps_fact_sales AS PARTITION pf_fact_sales TO (';

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
    CREATE TABLE fact_sales (
        order_id VARCHAR(50) NOT NULL,
        customer_key INT,
        territory_key INT,
        product_key INT,
        store_key INT,
        order_date_dateorders INT,
        shipping_date_dateorders INT,
        order_time INT,
        shipping_time INT,
        delivery_status_key INT,
        transaction_key INT,
        delivery_risk_key INT,
        order_status_key INT,
        shipping_mode_key INT,
        sales FLOAT,
        order_item_discount FLOAT,
        order_profit_per_order FLOAT,
        order_item_quantity INT
    )
    ON ps_fact_sales(order_date_dateorders); -- Use the partition scheme

    -- DROP TABLE #PartitionBoundaries

END