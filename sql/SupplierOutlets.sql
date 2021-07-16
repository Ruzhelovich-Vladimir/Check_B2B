DECLARE @supplierid INT 
SET @supplierid = @supplier_id
select 
so.SupplierId [Саплайр ИД]
,so.CustomerId [Идентификатор точки синхронизации]
,so.ExternalCode [Внешний код]
,so.SupplierOutletCode [Код поставщика]
,so.SupplierOutletName [Имя поставщика]
,so.SupplierOutletTradingName [Торговое наименование торговой точки]
,so.SupplierOutletAddress [Адрес ТТ]
,so.SupplierOutletDeliveryAddress [Адрес доставки]
,so.ClassificationId [Идентификатор классификации]
,so.NetworkId [Идентификатор сети ТТ]
,so.GeographyId [Идентификатор объекта географии]
,so.CountryId [Идентификатор страны]
,so.Status [Статус (2 - активная, 9 - неактивная)]
,so.OnlineOrderDiscount [Cкидка онлайн заказа]
,so.OutletId [Идентификатор торговой точки]
,so.MappingSupplierUserId [Идентификатор пользователя поставщика]
,so.MappingDate [Дата сопоставления]
,so.ActivationRequestId [Идентификатор запроса на активацию]
,so.OlGroupName [Каналы продаж]
,so.SupplierOutletId [ИД Клиента]	
from SupplierOutlets so
where  so.SupplierId=@supplierid and so.Status=2