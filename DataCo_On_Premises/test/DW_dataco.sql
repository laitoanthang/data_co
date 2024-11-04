USE DW_Dataco
SELECT * FROM category

--DELETE FROM category WHERE category_key IN (2,3,4)
SELECT * FROM 
USE DB_staging
EXEC sp_iload_create_department

SELECT *
FROM dataco_orders
WHERE CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01'
ORDER BY CONVERT(DATETIME, order_date_dateorders, 101) ASC
/*
delete statement
DELETE FROM dataco_orders
WHERE ISDATE(order_date_dateorders) = 1 
AND CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01';
*/


/*
-- update department
UPDATE dataco_orders
SET department_name = 'Fan Shop 1'
WHERE ISDATE(order_date_dateorders) = 1
AND CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01' AND department_name = 'Fan Shop';
*/


SELECT category_id, category_Name, department_id, department_name, product_card_id, product_name FROM dataco_orders
WHERE department_name = 'Fan Shop 1'
/*
Trường hợp 1: category name thay đổi 
Fishing
*/ 

UPDATE dataco_orders 
SET category_name = 'Fishing 1'
WHERE department_name = 'Fan Shop 1' AND category_name = 'Fishing'

/*
Trường hợp 2: Có 1 category chuyển từ department này sang department khác
10 Strength Training
*/
SELECT category_id, category_Name, department_id, department_name, product_card_id, product_name 
FROM dataco_orders
WHERE CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01' AND category_name = 'Strength Training'
ORDER BY CONVERT(DATETIME, order_date_dateorders, 101) ASC



UPDATE dataco_orders
SET department_name = 'Fan Shop 1', department_id = '7'
WHERE ISDATE(order_date_dateorders) = 1
AND CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01'
AND category_name = 'Strength Training';



SELECT DISTINCT category_id, category_name,department_id, department_name
FROM dataco_orders 
WHERE category_name = 'Strength Training';