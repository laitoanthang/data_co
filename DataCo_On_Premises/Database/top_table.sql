USE DW_Dataco
SELECT TOP 100 
    s.name AS SchemaName, 
    t.name AS TableName, 
    p.rows AS 'RowCount'
FROM 
    sys.tables AS t
INNER JOIN 
    sys.indexes AS i ON t.object_id = i.object_id
INNER JOIN 
    sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN 
    sys.schemas AS s ON t.schema_id = s.schema_id
WHERE 
    t.is_ms_shipped = 0 AND i.index_id IN (0, 1)
GROUP BY 
    s.name, t.name, p.rows
ORDER BY 
    p.rows DESC;


EXEC sp_msforeachtable 'DELETE FROM ?';
