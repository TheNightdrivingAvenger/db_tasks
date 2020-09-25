--- TASK (variant) #6 ---

-- a) add EmailAddress
alter table dbo.Person
  add
    EmailAddress nvarchar(50) null;
----------------------

-- b) table variable 
select * into #tempPerson
  from dbo.Person;

update #tempPerson
  set #tempPerson.EmailAddress = ea.EmailAddress
  from #tempPerson as tp
  join Person.EmailAddress as ea
    on tp.BusinessEntityID = ea.BusinessEntityId
----------------------

-- c) updating field from temp table
update dbo.Person
  set dbo.Person.EmailAddress = replace(tp.EmailAddress, '0', '')
  from #tempPerson as tp
  where tp.BusinessEntityId = dbo.Person.BusinessEntityID;
----------------------

-- d) remove person with 'Work' contact typess
delete from dbo.Person
  from dbo.Person as p
  join Person.PersonPhone as pp
    on pp.BusinessEntityID = p.BusinessEntityID
  join Person.PhoneNumberType as pnt
    on pnt.PhoneNumberTypeID = pp.PhoneNumberTypeID
  where pnt.Name = 'Work'
----------------------

-- e) remove 'EmailAddress' and all constraints

alter table dbo.Person
  drop column EmailAddress

select *
  from AdventureWorks2012.INFORMATION_SCHEMA.TABLE_CONSTRAINTS--CONSTRAINT_COLUMN_USAGE--.CONSTRAINT_TABLE_USAGE
  where TABLE_SCHEMA = 'dbo' and TABLE_NAME = 'Person';

select
  default_constraints.name
from sys.all_columns
  join sys.tables
    on all_columns.object_id = tables.object_id
  join sys.schemas
    on tables.schema_id = schemas.schema_id
  join sys.default_constraints
    on all_columns.default_object_id = default_constraints.object_id
  where schemas.name = 'dbo'
    and tables.name = 'Person'

alter table dbo.Person
  drop constraint PK_PersonID_and_Type, PersonType_Domain_Check, Title_DefaultValue
----------------------

-- f) drop the table
drop table dbo.Person
----------------------
