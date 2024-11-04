USE DW_Dataco
SELECT * FROM department
SELECT * FROM category

DELETE FROM category 
WHERE category_key BETWEEN 34 AND 43;


DELETE FROM department WHERE department_key IN (7,8,9,10)
UPDATE department
SET is_valid = 1

update category
SET is_valid =  1,end_date = '9999-12-31'
WHERE department_key = 6

SELECT * FROM category WHERE category_name = 'Fishing'

SELECT * FROM department
