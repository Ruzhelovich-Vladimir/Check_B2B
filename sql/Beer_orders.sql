select 
SupplierOutletCode,CreationDate,TotalAmount from Orders o inner join SupplierOutlets so on o.SupplierOutletId=so.SupplierOutletId
where wid=1401 and CreationDate>='2021-02-01'