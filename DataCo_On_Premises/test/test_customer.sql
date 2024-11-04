USE DB_staging

EXEC sp_iload_create_dim_customer




UPDATE dataco_orders 
SET customer_fname = 'Tien', customer_lname  = 'Dinh' 
WHERE order_id = '68866'