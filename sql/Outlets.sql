/*Связь ТТ со складом outletToWarehouse, дни доставки*/
DECLARE @supplierid INT 
SET @supplierid = @supplier_id
select 
ROW_NUMBER() OVER(ORDER BY so.ExternalCode ASC) [Номер] 
,o.OutletId [Идентификатор ТТ]
,so.ExternalCode [Внешний код]
,o.Name [Название ТТ]
,o.Address [Адрес]
,o.INN [Инвентаризационный номер]
,o.JuridicalName [Юридическое название]
,so.SupplierOutletName [Имя поставщика УСД]
,so.SupplierOutletTradingName [Торговое наименование торговой УСД]
,so.SupplierOutletAddress [Адрес ТТ УСД]
,so.SupplierOutletDeliveryAddress [Адрес доставки УСД]
,o.DLM [Дата последней модификации клиента]
,so.MappingDate [Дата сопоставления УСД]
,PayFormName [Форма оплаты]
,count(1) [Кол-во складов]
,MAX(ISNULL(pai.Sale,0)) [Максимальная скидка по акции]
from Outlets o
inner join SupplierOutlets so on o.OutletId = so.OutletId and so.Status = 2
left join SupplierOutletsToWarehouse otw on otw.SupplierOutletId=so.SupplierOutletId
LEFT JOIN Warehouses wh ON otw.W_ID = wh.W_ID and wh.Status = '2'
left join SupplierOutletsByPayForms sopf on so.SupplierOutletId=sopf.SupplierOutletId
left join PayForms pf on pf.PayFormId=sopf.PayFormId and pf.status=2
left join [promo].ActivitiesByOutlet pao on pao.Status=2 and  pao.SupplierOutletId=so.SupplierOutletId
left join [promo].ActivitiesByItem pai on pai.Status=2 and  pao.PromoActivitiesId=pai.PromoActivitiesId
where so.SupplierId= @supplierid and o.Status=2
group by 
o.OutletId
,so.ExternalCode
,o.Name
,o.Address
,o.INN
,o.JuridicalName
,so.SupplierOutletName
,so.SupplierOutletTradingName
,so.SupplierOutletAddress
,so.SupplierOutletDeliveryAddress
,o.DLM
,so.MappingDate
,PayFormName
