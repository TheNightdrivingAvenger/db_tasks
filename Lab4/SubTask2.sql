--- TASK (variant) #6 ---

use AdventureWorks2012
go

-- a) creating the Phone + PhoneType view and clustered index
create view Person.PersonPhoneWithType
  with schemabinding
as
  select pp.BusinessEntityID
       , pp.PhoneNumber
       , pp.PhoneNumberTypeID
       , pp.ModifiedDate as PhoneModifiedDate
       , pnt.Name
       , pnt.ModifiedDate as PhoneTypeModifiedDate
    from Person.PersonPhone as pp
    join Person.PhoneNumberType as pnt
      on pp.PhoneNumberTypeID = pnt.PhoneNumberTypeID;
go

create unique clustered index IX_NumberTypeID_EntityID
  on Person.PersonPhoneWithType (PhoneNumberTypeId, BusinessEntityID)
go
----------------------
-- b) creating the trigger.
--   It is pretty complex, because it's one trigger for all operations.
--   I've tried to make it as simple as possible, so UPDATE is a sequence of "DELETE -> INSERT".
--   Even Microsoft says that the UPDATE may be considered like this in triggers :)
create trigger Person.AlterPersonPhoneAndType
  on Person.PersonPhoneWithType
  instead of insert, update, delete
as
-- delete the records from person's phone if any are deleted
  declare @rowsToDelete as table (
    BusinessEntityID int not null
  , PhoneNumber Phone not null
  , PhoneNumberTypeID int not null
  );

  insert into @rowsToDelete
    (BusinessEntityID, PhoneNumber, PhoneNumberTypeID)
    select deleted.BusinessEntityID
         , deleted.PhoneNumber
         , deleted.PhoneNumberTypeID
      from deleted
      join Person.PersonPhone as pp
            on pp.BusinessEntityID = deleted.BusinessEntityID
           and pp.PhoneNumber = deleted.PhoneNumber
           and pp.PhoneNumberTypeID = deleted.PhoneNumberTypeID;

  delete
    from Person.PersonPhone
    where BusinessEntityID in
        (select BusinessEntityID from @rowsToDelete)
      and PhoneNumber in
        (select PhoneNumber from @rowsToDelete)
      and PhoneNumberTypeID in
        (select PhoneNumberTypeID from @rowsToDelete);
    
  if (not exists(select 1 from Person.PersonPhone as pp
                   join deleted
                     on pp.PhoneNumberTypeID = deleted.PhoneNumberTypeID))
  begin
    -- there're no more records referencing these values in PhoneNumberType, we can remove them
    delete
      from Person.PhoneNumberType
      where PhoneNumberTypeID in
        (select PhoneNumberTypeID from deleted);
  end;

  merge Person.PhoneNumberType as target
  using inserted as source
  on source.PhoneNumberTypeID = target.PhoneNumberTypeID
  when matched then
    update
      set target.Name = source.Name
        , target.ModifiedDate = source.PhoneTypeModifiedDate
  when not matched then
    insert
    (Name, ModifiedDate)
    values
      (source.Name, source.PhoneTypeModifiedDate);

  with inserted_with_types_IDs as (
    select inserted.BusinessEntityID
         , inserted.PhoneNumber
         , pnt.PhoneNumberTypeID
         , pnt.Name
         , inserted.PhoneModifiedDate
    from inserted
      join Person.PhoneNumberType as pnt
        on pnt.Name = inserted.Name
  )
  insert into Person.PersonPhone
    (BusinessEntityID, PhoneNumber, PhoneNumberTypeID, ModifiedDate)
    select inserted_with_types_IDs.BusinessEntityID
         , inserted_with_types_IDs.PhoneNumber
         , inserted_with_types_IDs.PhoneNumberTypeID
         , inserted_with_types_IDs.PhoneModifiedDate
    from inserted_with_types_IDs
----------------------

-- c) checking the trigger
insert into Person.PersonPhoneWithType
  (BusinessEntityID, PhoneNumber, PhoneModifiedDate, Name, PhoneTypeModifiedDate)
  values
    (1, N'123-456-7890', getdate(), N'Test phone2', getdate());

select * from Person.PersonPhone;
select * from Person.PhoneNumberType;
select * from Person.PersonPhoneWithType;

update Person.PersonPhoneWithType
  set PhoneNumber = N'098-765-4321'
    , PhoneModifiedDate = getdate()
    , Name = N'Test phone #2'
    , PhoneTypeModifiedDate = getdate()
  where
    PhoneNumber = N'123-456-7890';

select * from Person.PersonPhone;
select * from Person.PhoneNumberType;
select * from Person.PersonPhoneWithType;

delete
  from Person.PersonPhoneWithType
  where Name = N'Test phone #2'

select * from Person.PersonPhone;
select * from Person.PhoneNumberType;
select * from Person.PersonPhoneWithType;
----------------------
