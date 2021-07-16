/*Склады  - productWarehouse*/
DECLARE @supplierid INT 
SET @supplierid = @supplier_id
SELECT 
ROW_NUMBER() OVER(ORDER BY ExternalCode ASC) [Номер] 
, W_ID [ИД]
, ExternalCode [КОД УС]
, WarehouseName [Наименование]
, AllowTareReturn [Возвратная тара] 
FROM Warehouses w 
where w.supplierid=@supplierid 
and w.status=2