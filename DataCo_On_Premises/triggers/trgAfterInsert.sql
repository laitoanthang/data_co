ALTER TRIGGER trgAfterInsert
ON [dataco_staging].[dbo].[dataco_orders]
AFTER INSERT
AS
BEGIN
    -- Actions to perform after an insert
    PRINT 'A row has been inserted. Message from Thang Lai'
    -- You can also log this action or perform other operations here.
END;



-- -- Trigger để cập nhật số lượng hàng tồn kho khi đơn hàng được thêm
-- CREATE TRIGGER trg_UpdateInventory
-- ON dbo.Orders
-- AFTER INSERT
-- AS
-- BEGIN
--     UPDATE Inventory
--     SET QuantityInStock = QuantityInStock - i.Quantity
--     FROM Inventory AS inv
--     INNER JOIN inserted AS i ON inv.ProductID = i.ProductID;
-- END;

-- -- Trigger để khôi phục số lượng hàng tồn kho khi đơn hàng bị xóa
-- CREATE TRIGGER trg_RestoreInventory
-- ON dbo.Orders
-- AFTER DELETE
-- AS
-- BEGIN
--     UPDATE Inventory
--     SET QuantityInStock = QuantityInStock + d.Quantity
--     FROM Inventory AS inv
--     INNER JOIN deleted AS d ON inv.ProductID = d.ProductID;
-- END;


SELECT 
    trg.name AS trigger_name,
    schema_name(tab.schema_id) + '.' + tab.name AS [table],
    CASE 
        WHEN is_instead_of_trigger = 1 THEN 'Instead of'
        ELSE 'After' 
    END AS [activation],
    (CASE 
        WHEN OBJECTPROPERTY(trg.object_id, 'ExecIsUpdateTrigger') = 1 THEN 'Update ' 
        ELSE '' 
     END +
     CASE 
        WHEN OBJECTPROPERTY(trg.object_id, 'ExecIsDeleteTrigger') = 1 THEN 'Delete ' 
        ELSE '' 
     END +
     CASE 
        WHEN OBJECTPROPERTY(trg.object_id, 'ExecIsInsertTrigger') = 1 THEN 'Insert' 
        ELSE '' 
     END) AS [event],
    CASE 
        WHEN trg.parent_class = 1 THEN 'Table trigger'
        WHEN trg.parent_class = 0 THEN 'Database trigger'
    END AS [class],
    CASE 
        WHEN trg.[type] = 'TA' THEN 'Assembly (CLR) trigger'
        WHEN trg.[type] = 'TR' THEN 'SQL trigger'
        ELSE '' 
    END AS [type],
    CASE 
        WHEN is_disabled = 1 THEN 'Disabled'
        ELSE 'Active' 
    END AS [status],
    OBJECT_DEFINITION(trg.object_id) AS [definition]
FROM sys.triggers trg
LEFT JOIN sys.objects tab ON trg.parent_id = tab.object_id
ORDER BY trg.name;

