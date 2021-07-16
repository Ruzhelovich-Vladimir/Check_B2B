/*Заказы*/
DECLARE @supplierid INT 
SET @supplierid = @supplier_id
select
ROW_NUMBER() OVER(ORDER BY so.ExternalCode ASC) [Номер] 
,o.OutletId [Идентификатор ТТ]
,so.ExternalCode [Внешний код]
,o.Name [Название ТТ]
,so.SupplierOutletTradingName [Торговое наименование торговой УСД]
,o.Address [Адес]
,o.INN [Инвентаризационный номер]
,so.SupplierOutletDeliveryAddress [Адрес доставки УСД]
,orders.OrderNo [Номер заказа]
,orders.TotalAmount [Сумма]
,orders.Comment [Комментарий]
,orders.DeliveryDate [Дата доставки]
from Outlets o
inner join SupplierOutlets so on o.OutletId = so.OutletId and so.Status = 2
inner join Orders orders on orders.SupplierOutletId = so.SupplierOutletId and orders.DeliveryDate >= GetDate()-5
where so.SupplierId=supplierid and o.Status=2
