--- TASK (variant) #6 ---

use AdventureWorks2012;
go

--- a) creating dbo.Person
create table dbo.Person (
  BusinessEntityID int          not null
, PersonType       nchar(2)     not null
, NameStyle        NameStyle    not null
, Title            nvarchar(8)  null
, FirstName        Name         not null
, MiddleName       Name         null
, LastName         Name         not null
, Suffix           nvarchar(10) null
, EmailPromotion   int          not null
, ModifiedDate     datetime     not null
)
----------------------

--- b) adding PK
alter table dbo.Person
  add constraint PK_PersonID_and_Type primary key clustered (BusinessEntityId, PersonType);
----------------------

--- c) adding constraint to the "PersonType" field
alter table dbo.Person
  add constraint PersonType_Domain_Check
    check (PersonType in ('GC', 'SP', 'EM', 'IN', 'VC', 'SC'))
----------------------

--- d) adding default for the "Title" field
alter table dbo.Person
  add constraint Title_DefaultValue
    default 'n/a' for Title
----------------------

-- TODO: nullable column Title doesn't want to work with default :(
--- e) filling the table
insert 
  into dbo.Person (BusinessEntityID,   PersonType,   NameStyle,   Title,   FirstName,   MiddleName,   LastName,   Suffix,   EmailPromotion,   ModifiedDate)
  select           p.BusinessEntityID, p.PersonType, p.NameStyle, p.Title, p.FirstName, p.MiddleName, p.LastName, p.Suffix, p.EmailPromotion, p.ModifiedDate
  from Person.Person p
  join Person.BusinessEntityContact bec
    on p.BusinessEntityID = bec.PersonID
  join Person.ContactType ct
    on ct.ContactTypeID = bec.ContactTypeID
  where ct.Name = 'Owner';
-- and setting the default values
update dbo.Person
  set Title = default
  where Title is null

--- f) alter the "Title" field
alter table dbo.Person
  alter column Title nvarchar(4) not null
----------------------
