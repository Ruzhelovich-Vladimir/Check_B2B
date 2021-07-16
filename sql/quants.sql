/*Кванты - quants*/
DECLARE @supplierid INT 
SET @supplierid = @supplier_id
SELECT 
pts.ExternalCode
,p.QuantQty
FROM [dbo].[Products] p
INNER JOIN [dbo].[ProductToSuppler] pts ON p.ProductId = pts.ProductId AND pts.Status = '2'
LEFT JOIN [dbo].[ProductInfo] pi ON pi.ProductId = pts.ProductId and pi.Status='2'
WHERE pts.supplierid = @supplierid