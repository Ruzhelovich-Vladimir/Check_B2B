SELECT 
SupplierId [Саплайр]
, W_ID [ИД]
, ExternalCode [КОД УС]
, WarehouseName [Наименование]
, AllowTareReturn [Возвратная тара] 
FROM Warehouses w 
where w.supplierid=@supplier_id and w.status=2