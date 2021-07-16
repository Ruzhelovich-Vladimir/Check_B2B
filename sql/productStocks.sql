/*Остатки товара на складе - productWarehouse, productStocks*/
DECLARE @supplierid INT 
SET @supplierid = @supplier_id
select
wh.W_ID [ИД]
,wh.ExternalCode [КОД УС]
,wh.WarehouseName [Наименование склада]
,wh.AllowTareReturn [Возвратная тара] 
,p.ProductId [ИД Продукта]
,p.ProductShortName [КОД Продукта]
,isnull(ps.ProductExternalCode,'') [КОД в остатках]
,p.ProductName [Наименование продукции]
,isnull(ps.Stock,0) [Остатки]
,isnull(ps.Dlm,'') [Дата ПМ остатки]
,isnull(p.Dlm,'') [Дата ПМ продукта]
from [dbo].[Products] p
inner join [dbo].[ProductToSuppler] pts on p.ProductId = pts.ProductId and pts.Status = '2'
left join [dbo].[ProductStocks] ps on p.ProductId = ps.ProductId and p.Status = '2'
inner join [dbo].[Warehouses] wh on ps.W_ID = wh.W_ID and wh.Status = '2'
where wh.supplierid=@supplierid and p.Status='2'
order by p.ProductName, p.ProductId, p.ProductShortName, wh.WarehouseName