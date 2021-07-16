/*Связь ТТ со складом Цены базовые+Скидки*/
DECLARE @supplierid INT
SET @supplierid = @supplier_id
select
TOP 20000
ROW_NUMBER() OVER(ORDER BY so.ExternalCode,ProductTechnicalName ASC) [Номер]
,o.OutletId [Идентификатор ТТ]
,so.ExternalCode [Внешний код]
,o.INN [Инвентаризационный номер]
,so.SupplierOutletName [Имя поставщика УСД]
,so.SupplierOutletDeliveryAddress [Адрес доставки УСД]
,PayFormName [Форма оплаты]
,p.ProductShortName [КодПродукта]
,p.productName [Наименование продукта]
,p.ProductTechnicalName [Наименование 1С]
,pl.Price [Цена c НДС]
,pl.VAT [Ставка НДС]
,ISNULL(promo.[Скидка],0) [Скидка]
from Outlets o
inner join SupplierOutlets so on o.OutletId = so.OutletId and so.Status = 2
left join SupplierOutletsToWarehouse otw on otw.SupplierOutletId=so.SupplierOutletId
LEFT JOIN Warehouses wh ON otw.W_ID = wh.W_ID and wh.Status = '2'
left join SupplierOutletsByPayForms sopf on so.SupplierOutletId=sopf.SupplierOutletId
inner join PayForms pf on pf.PayFormId=sopf.PayFormId and pf.status=2
inner join PriceLists pl on pl.PayFormId=pf.PayFormId
inner join Products p on p.ProductId=pl.ProductId and p.status=2
left join (
    SELECT
    ao.SupplierOutletId [SupplierOutletId]
    ,ai.ProductId [ProductId]
    ,Max(Sale) [Скидка] FROM
    [promo].Activities a
    inner join [promo].ActivitiesByItem ai on a.PromoActivitiesId=ai.PromoActivitiesId and ai.Status=2
    inner join [promo].ActivitiesByOutlet ao on a.PromoActivitiesId=ao.PromoActivitiesId and ao.Status=2
    where a.SupplierId=@SupplierId and a.status=2 and GETDATE() between a.DateFrom and a.DateTo
    group by [ProductId], [SupplierOutletId]
) promo on promo.SupplierOutletId=so.SupplierOutletId and promo.ProductId=p.ProductId
where  so.SupplierId= @supplierid and o.Status=2
--and trim(so.ExternalCode) in ('104890000000996')