-- /*Продукты - Цены*/
-- DECLARE @supplierid INT
-- SET @supplierid = @supplier_id
-- select TOP 9999
-- ROW_NUMBER() OVER(ORDER BY p.ProductShortName ASC) [Номер]
-- ,p.ProductId [ИД]
-- ,p.ProductShortName [Внешний код продукта]
-- ,p.ProductName [Наименование продукта]
-- ,p.ProductTechnicalName [Техническое название продукта]
-- ,p.UnitType [Тип фасовки]
-- ,p.ProductVolume [Базовый объем]
-- ,pl.Price [Цена]
-- ,pf.PayFormName [Форма оплаты]
-- ,isnull(p.DLM,'') [Дата ПМ продукта]
-- ,isnull(pts.DLM,'') [Дата ПМ EAN]
-- ,isnull(pf.DLM,'') [Дата ПМ цен]
-- from [dbo].[Products] p
-- inner join [dbo].[ProductToSuppler] pts on p.ProductId = pts.ProductId and pts.Status = '2'
-- left join [dbo].[PriceLists] pl on p.ProductId = pl.ProductId and p.Status = '2'
-- left join [dbo].[PayForms] pf on pl.PayFormId=pf.PayFormId and pf.Status = '2'
-- where pts.supplierid = @supplierid and p.Status='2'
-- order by pf.PayFormName,p.ProductVolume,pl.Price

/*Продукты - Цены*/
DECLARE @supplierid INT
SET @supplierid = @supplier_id
select TOP 9999
ROW_NUMBER() OVER(ORDER BY p.ProductShortName ASC) [Номер],
so.ExternalCode [Код ТТ],
,pf.PayFormName [Форма оплаты]
,p.ProductId [ИД]
,p.ProductShortName [Внешний код продукта]
,p.ProductName [Наименование продукта]
,p.ProductTechnicalName [Техническое название продукта]
,p.UnitType [Тип фасовки]
,p.ProductVolume [Базовый объем]
,pl.Price [Цена]
,isnull(p.DLM,'') [Дата ПМ продукта]
,isnull(pts.DLM,'') [Дата ПМ EAN]
,isnull(pf.DLM,'') [Дата ПМ цен]
from [dbo].[Products] p
inner join [dbo].[ProductToSuppler] pts on p.ProductId = pts.ProductId and pts.Status = '2'
left join [dbo].[PriceLists] pl on p.ProductId = pl.ProductId and p.Status = '2'
left join [dbo].[PayForms] pf on pl.PayFormId=pf.PayFormId and pf.Status = '2'
left join [dbo].[SupplierOutletsByPayForms] opf on opf.PayFormId=pf.PayFormId
left join [dbo].[SupplierOutlets] so on opf.SupplierOutletId=so.SupplierOutletId
where pts.supplierid = @supplierid and p.Status='2'
--and so.ExternalCode in ('50854789','50941831','51058985','51069360','78002193','78003081','78003133','43801000754','63801001844','104890000000064','104890000000864','104890000000922','104890000001392','108720000000168')
order by pf.PayFormName,p.ProductVolume,pl.Price