USE DB_staging

--DELETE FROM dataco_orders


SELECT department_id,department_name, category_id, category_name,product_card_id,product_name FROM dataco_orders
WHERE CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01'
ORDER BY CONVERT(DATETIME, order_date_dateorders, 101) ASC

-- DEPARTMENT 
--TH 1: department_name thay đổi --> tao deparment key moi --> thay doi key trong category 
UPDATE dataco_orders 
SET department_name = 'Fan Shop 1'
WHERE department_name = 'Fan Shop' AND CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01'

-- check department
SELECT * FROM DW_Dataco.dbo.department 

-- check category
SELECT * FROM DW_Dataco.dbo.category 

--TH 2: department_name mới
-- check department 
SELECT * FROM DW_Dataco.dbo.department 

-- CATEGORY
-- TH 1: category name thay đổi --> thêm category key mới --> thêm category mới vào dim product
UPDATE dataco_orders 
SET category_name = 'Strength Training 1'
WHERE category_name = 'Strength Training' AND CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01' 


-- check category 
SELECT * FROM DW_Dataco.dbo.category 
-- check dim product
SELECT * FROM DW_Dataco.dbo.dim_product WHERE is_valid = 0
ORDER BY category_key ASC


-- TH 2: category name mới --> thêm category key mới là được
-- check category 
SELECT * FROM DW_Dataco.dbo.category 

-- DIM PRODUCT
-- TH1: product name thay đổi 
-- Dell Laptop

UPDATE dataco_orders
SET product_name = 'Dell Laptop 1'
WHERE product_name ='Dell Laptop'  AND CONVERT(DATETIME, order_date_dateorders, 101) > '2017-10-01'  

-- check dim product
SELECT * FROM DW_Dataco.dbo.dim_product WHERE is_valid = 0

-- check product cũ chuyển thành is_valid = 0 chưa, giá trị mới được thêm vào chưa

-- TH2: Product mới được thêm vào 
-- chỉ cần kiểm tra



