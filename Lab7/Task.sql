--- TASK (variant) #6 ---
use AdventureWorks2012
go

-- create a stored procedure for filling a table with XML values
create procedure Sales.ReadCardsFromXML @xmlValues XML
as
  select CreditCardID = xmlNode.value(N'@ID', 'int')
       , CardType = xmlNode.value(N'@Type', 'nvarchar(50)')
       , CardNumber = xmlNode.value(N'@Number', 'nvarchar(25)')
    from @xmlValues.nodes(N'/CreditCards/Card') as XML(xmlNode);
go

----------------------

-- select values into XML
declare @xmlRes XML;

set @xmlRes =
  (select CreditCardID as N'@ID'
        , CardType as N'@Type'
        , CardNumber as N'@Number'
     from Sales.CreditCard
  for XML path(N'Card'), root(N'CreditCards'));

select @xmlRes;
----------------------

-- exec the procedure to check
exec Sales.ReadCardsFromXML @xmlRes
go
