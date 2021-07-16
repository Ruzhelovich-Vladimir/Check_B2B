
/*Продукты - loadProduct, uploadProductsImages,quants*/
DECLARE @supplierid INT 
SET @supplierid = @supplier_id
select 
ROW_NUMBER() OVER(ORDER BY p.ProductShortName ASC) [Номер]
,p.ProductId [ИД]
,p.ProductShortName [Внешний код продукта]
,p.ProductName [Наименование продукта]
,p.ProductTechnicalName [Техническое название продукта]
,isnull(pi.Description,'') [Описание]
,p.UnitType [Тип фасовки]
,p.ProductVolume [Базовый объем]
,p.IsMix [Mix]
,p.QuantQty [Квант]
,p.QuantUnitType [Тип еденицы]
,isnull(pts.EanCode,'') [EAN]
,isnull(pi.Expiration,0) [Срок годности]
,isnull(pi.IsAlc,0) [Признак алкогольной продукции]
,isnull(pi.IsTare,0) [Признак тары]
,isnull(pi.PictureId,9999) [Номер пиктограммы для карточки]
,string_agg(isnull(FileUniqueName,''), ',') [Фотография]
,max(ISNULL(ps.Stock,0)) [Максимальные остатки]
,isnull(p.DLM,'') [Дата ПМ продукта]
,isnull(pi.DLM,'') [Дата ПМ доп информации]
,isnull(pts.DLM,'') [Дата ПМ EAN]
,max(isnull(ps.DLM,'')) [Дата ПМ остатков]
from [dbo].[Products] p 
inner join [dbo].[ProductToSuppler] pts on p.ProductId = pts.ProductId and pts.Status = '2' 
inner join [dbo].[ProductInfo] pi on pi.ProductId = pts.ProductId and pi.Status='2' 
left join [dbo].[ProductContents] pc on pc.ProductId = pts.ProductId
left join [dbo].[ProductStocks] ps on p.ProductId = ps.ProductId and p.Status = '2'
where 
pts.supplierid = @supplierid 
and p.Status='2'
group by
p.ProductId
,p.ProductShortName
,p.ProductName
,p.ProductTechnicalName
,isnull(pi.Description,'')
,p.UnitType
,p.ProductVolume
,p.IsMix
,p.QuantQty
,p.QuantUnitType
,isnull(pts.EanCode,'')
,isnull(pi.Expiration,0)
,isnull(pi.IsAlc,0)
,isnull(pi.IsTare,0)
,isnull(pi.PictureId,9999)
,isnull(p.DLM,'') 
,isnull(pi.DLM,'')
,isnull(pts.DLM,'')


