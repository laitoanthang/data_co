USE DW_Dataco

SELECT * FROM fact_monthly_kpi
WHERE date_key = 20170131 AND store_key = 4774
GROUP BY store_key, date_key

SELECT customer_key, order_id FROM fact_sales fs JOIN dim_date dd 
ON fs.order_date_dateorders = dd.date_key
WHERE store_key = 3 AND year = 2017 AND MONTH = 1
SELECT * FROM fact_monthly_kpi

WITH CTE_Duplicates AS (
    SELECT 
        store_key,
        num_cus_return,
        total_cus_month,
        date_key,
        ROW_NUMBER() OVER (PARTITION BY store_key, date_key, actual_sales,actual_profit,num_cus_return, total_cus_month, on_time_orders, total_orders_month ORDER BY (SELECT NULL)) AS row_num
    FROM fact_monthly_kpi
)
DELETE FROM CTE_Duplicates
WHERE row_num > 1;

SELECT * FROM fact_monthly_kpi
WHERE date_key = 20170131 AND store_key = 4774

WITH  delivery_status_4_cte AS (
	SELECT 
		dd.year, 
		dd.month, 
		o.store_key, 
		COUNT(delivery_status_key) AS on_time_delivery
	FROM 
		(SELECT 
			order_id, delivery_status_key, order_date_dateorders, store_key 
		FROM 
			fact_sales 
		GROUP BY 
			order_id, delivery_status_key, order_date_dateorders, store_key
		) AS o
	LEFT JOIN 
		DW_dataco.dbo.dim_date dd 
	ON 
		o.order_date_dateorders = dd.date_key
	WHERE 
		delivery_status_key = 2
	GROUP BY 
		dd.year, dd.month, o.store_key
),
total_cte AS (
	SELECT 
		dd.year, 
		dd.month, 
		o.store_key, 
		COUNT(o.delivery_status_key) AS total_delivery_status,
		SUM(o.sales) AS actual_sales,
		SUM(o.order_profit_per_order) AS actual_profit
	FROM 
		(SELECT 
			order_id, 
			delivery_status_key, 
			customer_key, 
			order_date_dateorders, 
			store_key, 
			sales,
			order_profit_per_order
		FROM 
			fact_sales 
		GROUP BY 
			order_id, 
			delivery_status_key, 
			order_date_dateorders, 
			customer_key, 
			store_key,
			sales,
			order_profit_per_order
		) AS o 
	LEFT JOIN 
		DW_dataco.dbo.dim_date dd ON o.order_date_dateorders = dd.date_key 
	GROUP BY 
		dd.year, dd.month, o.store_key
),
total_cus AS (
	SELECT 
		dd.year,
		dd.month,
		store_key,
		COUNT(DISTINCT o.customer_key) AS total_customer
	FROM 
		fact_sales o
	LEFT JOIN 
		DW_dataco.dbo.dim_date dd ON dd.date_key = o.order_date_dateorders
	GROUP BY 
		dd.year, dd.month, store_key
),
cus_cte AS (
	SELECT 
		year, 
		month, 
		store_key, 
		SUM(CASE WHEN num_orders_in_month >= 2 THEN 1 ELSE 0 END) as num_cus_return
	FROM (
		SELECT 
			dd.year,
			dd.month,
			o.customer_key,
			o.store_key,
			COUNT(DISTINCT o.order_id) AS num_orders_in_month
		FROM 
			DW_dataco.dbo.dim_date dd
		LEFT JOIN 
			fact_sales o ON dd.date_key = o.order_date_dateorders AND o.order_date_dateorders <= (SELECT MAX(order_date_dateorders) FROM fact_sales)
		GROUP BY 
			dd.year, dd.month, o.customer_key, o.store_key
	) as subquery
	GROUP BY 
		year, month, store_key
)
SELECT 
    FORMAT(EOMONTH(CONVERT(DATE, CONCAT(ds.year, '-', ds.month, '-01'))), 'yyyyMMdd') AS date_key,
    ds.store_key, 
    ds.on_time_delivery,
    tc.total_delivery_status, 
    cc.num_cus_return, 
    tcus.total_customer, 
    tc.actual_sales, 
    tc.actual_profit
FROM 
    delivery_status_4_cte ds 
JOIN
    total_cte tc ON ds.year = tc.year AND ds.month = tc.month AND ds.store_key = tc.store_key
JOIN 
    cus_cte cc ON ds.year = cc.year AND ds.month = cc.month AND ds.store_key = cc.store_key
JOIN 
    total_cus tcus ON tcus.year = cc.year AND tcus.month = cc.month AND tcus.store_key = cc.store_key

WHERE tcus.year = 2017 AND tcus.month = 1 AND ds.store_key = 3

