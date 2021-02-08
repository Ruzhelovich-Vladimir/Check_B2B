SELECT 
p.ProductId [ИД]
,p.ProductShortName [Внешний код продукта]
,p.ProductName [Наименование продукта]
,p.ProductTechnicalName [Техническое название продукта]
,pi.Description [Описание]
,p.UnitType [Тип фасовки]
,p.ProductVolume [Базовый объем]
,p.IsMix [Mix]
,p.QuantQty [шт/уп]
,p.QuantUnitType [Тип еденицы]
,pts.EanCode [EAN]
/*
,pi.Composition [Состав]
,pi.Expiration [Срок годности]
,pi.StorageRequirenments [Условия хранения]
,pi.NormativeDocument [Номер нормативного документа.]
,pi.ProductCode [Код продукции]*/
,pi.IsAlc [Признак алкогольной продукции]
,pi.IsTare [Признак тары]
,pi.PictureId [Номер пиктограммы для карточки]
,p.DLM [Дата последней модификации (карточка)]
,pi.DLM [Дата последней модификации (информация)]
,pts.DLM [Дата последней модификации (EAN)]
,FileUniqueName [Фотография]
FROM [dbo].[Products] p 
INNER JOIN [dbo].[ProductToSuppler] pts ON p.ProductId = pts.ProductId AND pts.Status = '2' 
INNER JOIN [dbo].[ProductInfo] pi ON pi.ProductId = pts.ProductId and pi.Status='2' 
LEFT JOIN [dbo].[ProductContents] pc ON pc.ProductId = pts.ProductId
WHERE pts.supplierid = @supplier_id and p.Status='2' 