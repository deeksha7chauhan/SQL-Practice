### Find out the average hard disk drive capacity of PCs produced by makers who also manufacture printers.
Result set: maker, average HDD capacity.

SELECT 
    p1.maker, 
    AVG(pc.hd) AS average_hdd
FROM 
    Product p1
JOIN 
    PC pc ON p1.model = pc.model
WHERE 
    p1.maker IN (
        SELECT DISTINCT p2.maker
        FROM Product p2
        WHERE p2.type = 'Printer'
    )
GROUP BY 
    p1.maker;

