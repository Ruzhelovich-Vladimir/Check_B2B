DECLARE @supplierid INT 
SET @supplierid = @supplier_id

(
select 
'#1_ТТ: Отсутствует связей со складом' [Тип ошибки]
,ROW_NUMBER() OVER(ORDER BY so.ExternalCode ASC) [Номер]
,CAST(so.ExternalCode as varchar) [Внешний код объкта]
,CAST(ISNULL(w.WarehouseName,'отсутствует') as varchar) [Значение]
,CAST(ISNULL(so.SupplierOutletTradingName,'') as varchar) [Описание]
from SupplierOutlets so
left join SupplierOutletsToWarehouse sow on so.SupplierOutletId=sow.SupplierOutletId and so.CustomerId=sow.CWId
left join Warehouses w on sow.W_ID=w.W_ID and w.status=2
where  so.SupplierId=@supplierid and so.Status=2 and w.WarehouseName is null
)
union all
(
select
'#2_ТТ: Нет дней доставки' [Тип ошибки]
,ROW_NUMBER() OVER(ORDER BY so.ExternalCode ASC) [Номер]
,CAST(so.ExternalCode as varchar) [Внешний код объкта]
,CAST(sod.DeliveryDate as varchar) [Значение]
,CAST(ISNULL(so.SupplierOutletTradingName,'отсутствует') as varchar) [Описание]
from SupplierOutlets so
inner join SupplierOutletsToWarehouse sow on so.SupplierOutletId=sow.SupplierOutletId and so.CustomerId=sow.CWId
inner join Warehouses w on sow.W_ID=w.W_ID and w.status=2
left join SupplierOutletDeliveries sod on so.SupplierOutletId=sod.SupplierOutletId and sod.Status=2 and sod.DeliveryDate>GETDATE()
where  so.SupplierId=@supplierid and so.Status=2 and sod.DeliveryDate is null
)
union all
(
select
'#3_ТТ: Тип операции не соответствует требованиям, связи с ТТ' [Тип ошибки]
,ROW_NUMBER() OVER(ORDER BY so.ExternalCode ASC) [Номер]
,CAST(so.ExternalCode as varchar) [Внешний код объкта]
,CAST(ISNULL(o.Name,'отсутствует') as varchar) [Значение]
,CONCAT(CAST(ISNULL(so.SupplierOutletTradingName,'') as varchar),'. Допустимые значения - ''Наличная - опт'',''Безналичная - опт'',''Наличная - розничная'',''Наличный'',''Безналичный'',''По договору'',
''Готівкова - опт'',''Безготівкова - опт'',''Готівкова - роздрібна''') [Описание]
from SupplierOutlets so
inner join SupplierOutletsToWarehouse sow on so.SupplierOutletId=sow.SupplierOutletId and so.CustomerId=sow.CWId
inner join Warehouses w on sow.W_ID=w.W_ID and w.status=2
left join Operations o on so.SupplierOutletId=o.SupplierOutletId and o.Status=2
where  so.SupplierId=@supplierid and so.Status=2 
and ISNULL(o.Name,'х') not in ('Наличная - опт','Безналичная - опт','Наличная - розничная','Наличный','Безналичный','По договору',
'Готівкова - опт','Безготівкова - опт','Готівкова - роздрібна')
)
union all
(
select
'#4_ТТ: Не привязано форма оплаты' [Тип ошибки]
,ROW_NUMBER() OVER(ORDER BY so.ExternalCode ASC) [Номер]
,CAST(so.ExternalCode as varchar) [Внешний код объкта]
,CAST(ISNULL(pf.PayFormName,'отсутствует') as varchar) [Значение]
,CAST(ISNULL(so.SupplierOutletName,'') as varchar) [Описание]
from SupplierOutlets so
inner join SupplierOutletsToWarehouse sow on so.SupplierOutletId=sow.SupplierOutletId
left join SupplierOutletsByPayForms sopf on so.SupplierOutletId=sopf.SupplierOutletId
left join PayForms pf on pf.PayFormId=sopf.PayFormId and pf.status=2
where so.SupplierId=@supplierid and so.Status=2 and pf.PayFormName is null
)
union all
(
select
'#5_ТТ: Больше 1 формы оплаты привязано' [Тип ошибки]
,ROW_NUMBER() OVER(ORDER BY so.ExternalCode ASC) [Номер]
,CAST(so.ExternalCode as varchar) [Внешний код объкта]
,'колличество: '+CAST(count(1) as varchar) [Значение]
,CAST(ISNULL(so.SupplierOutletName,'') as varchar) [Описание]
from SupplierOutlets so
inner join SupplierOutletsToWarehouse sow on so.SupplierOutletId=sow.SupplierOutletId
inner join SupplierOutletsByPayForms sopf on so.SupplierOutletId=sopf.SupplierOutletId
inner join PayForms pf on pf.PayFormId=sopf.PayFormId and pf.status=2
where so.SupplierId=@supplierid and so.Status=2 
group by so.ExternalCode,so.SupplierOutletName having count(1)>1
)
union all
(
select 
'#6_SKU: Нет кванта' [Тип ошибки]
,ROW_NUMBER() OVER(ORDER BY pts.ExternalCode ASC) [Номер]
,CAST(pts.ExternalCode as varchar) [Внешний код объкта]
,CAST(ISNULL(p.QuantQty,'отсутствует') as varchar) [Значение]
,CAST(ISNULL(p.ProductTechnicalName,'') as varchar) [Описание]
from Products p
inner join ProductToSuppler pts on p.ProductId = pts.ProductId and pts.Status = '2'
where pts.supplierid=@supplierid and p.Status='2' and isnull(p.QuantQty,1)<2
)
union all
(
select 
'#7_SKU PRICE: Цена слишком маленькая' [Тип ошибки]
,ROW_NUMBER() OVER(ORDER BY pts.ExternalCode ASC) [Номер]
,CAST(pts.ExternalCode as varchar) [Внешний код объкта]
,CAST(ISNULL(pl.Price,'отсутствует') as varchar) [Значение]
,CAST(ISNULL(p.ProductTechnicalName,'') as varchar) [Описание]
from Products p
inner join ProductToSuppler pts on p.ProductId = pts.ProductId and pts.Status = '2'
inner join PriceLists pl on pts.ProductId=pl.ProductId
inner join PayForms pf on pf.PayFormId=pl.PayFormId and pf.status=2
where pts.supplierid=@supplierid and p.Status='2' and ISNULL(pl.Price,0)<4
)
union all
(
select 
'#8_SKU: Нет фотографии' [Тип ошибки]
,ROW_NUMBER() OVER(ORDER BY pts.ExternalCode ASC) [Номер]
,CAST(pts.ExternalCode as varchar) [Внешний код объкта]
,CAST(ISNULL(FileUniqueName,'отсутствует') as varchar) [Значение]
,CAST(ISNULL(p.ProductTechnicalName,'') as varchar) [Описание]
from [dbo].[Products] p 
inner join [dbo].[ProductToSuppler] pts on p.ProductId = pts.ProductId and pts.Status = '2'
inner join [dbo].[ProductStocks] ps on p.ProductId = ps.ProductId and p.Status = '2' and ps.Stock>0
left join [dbo].[ProductContents] pc on pc.ProductId = pts.ProductId
where 
pts.supplierid = @supplierid and p.Status='2' and FileUniqueName is null
)
order by [Тип ошибки],[Номер]