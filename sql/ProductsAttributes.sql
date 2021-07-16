/*Атрибуты, фильтры - uploadProductsAttributs*/
DECLARE @supplierid INT 
SET @supplierid = @supplier_id
SELECT
ROW_NUMBER() OVER(ORDER BY p.ProductName, p.ProductId, p.ProductShortName,pac.FilterName ASC) [Номер]  
,p.ProductId [ИД]
,p.ProductShortName [КОД]
,p.ProductName [Имя продукции]
,pac.value [Значение]
,pac.FilterName [ИмяФильтра]
,pac.DLM [Дата последней модификации (классификации)]
,p.DLM [Дата последней модификации (продукта)]
FROM [dbo].[Products] p
INNER JOIN [dbo].[ProductToSuppler] pts ON p.ProductId = pts.ProductId AND pts.Status = '2'
LEFT JOIN [dbo].[ProductWithFilterAttribute] pac ON p.ProductId = pac.ProductId AND pac.Status = '2'
WHERE pts.supplierid = @supplierid
and p.Status='2'
ORDER BY p.ProductName, p.ProductId, p.ProductShortName, pac.FilterName

-- SELECT
-- ROW_NUMBER() OVER(ORDER BY p.ProductName, p.ProductId, p.ProductShortName, pac.AltUnitType ASC) [Номер]  
-- ,p.ProductId [ИД]
-- ,p.ProductShortName [КОД]
-- ,p.ProductName [Имя продукции]
-- ,pac.AltUnitQty [Альтервнативная ЕИ]
-- ,pac.AltUnitType [Тип альтервнативной ЕИ]
-- ,pac.DLM [Дата последней модификации (классификации)]
-- ,p.DLM [Дата последней модификации (продукта)]
-- FROM [dbo].[Products] p
-- INNER JOIN [dbo].[ProductToSuppler] pts ON p.ProductId = pts.ProductId AND pts.Status = '2'
-- LEFT JOIN [dbo].[ProductsByAltConsumerUnits] pac ON p.ProductId = pac.ProductId AND pac.Status = '2'
-- WHERE pts.supplierid = @supplier_id
-- and p.Status='2'
-- ORDER BY p.ProductName, p.ProductId, p.ProductShortName, pac.AltUnitType

/*Атрибуты, фильтры - uploadProductsAttributs*/