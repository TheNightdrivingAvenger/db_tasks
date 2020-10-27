--- TASK (variant) #6 ---

use AdventureWorks2012
go

-- a) creating Person.PhoneNumberTypeHst
create table Person.PhoneNumberTypeHst (
  ID int identity(1, 1)
, Action nchar(6) not null
, ModifiedDate datetime not null
, SourceID int not null -- I could make it an FK constraint,
                        -- but this would make storing stats about deleted rows impossible (or non-informative with nulls)
, UserName nvarchar(256)
);
go
----------------------

-- b) creating triggers
-- insert
create trigger Person.PhoneNumberHistoryInsert
  on Person.PhoneNumberType
  after insert
as
  insert into Person.PhoneNumberTypeHst
    (Action, ModifiedDate, SourceID, UserName)
  select N'insert' as Action
       , getdate() as ModifiedDate
       , PhoneNumberTypeID
       , CURRENT_USER as UserName
  from inserted;
go

-- update
-- I didn't know what exactly I needed to log here, there are several options:
--   1. Log the update of the row before it is updated (from 'deleted')
--   2. Log the update of the new row after it is updated (from 'inserted', I did just that)
--   3. Log both the old and the new rows (from both 'deleted' and 'inserted')
create trigger Person.PhoneNumberHistoryUpdate
  on Person.PhoneNumberType
  after update
as
  insert into Person.PhoneNumberTypeHst
    (Action, ModifiedDate, SourceID, UserName)
  select N'update' as Action
       , getdate() as ModifiedDate
       , PhoneNumberTypeID
       , CURRENT_USER as UserName
  from inserted; -- contains the updated rows, no need to join with deleted
go

-- delete
create trigger Person.PhoneNumberHistoryDelete
  on Person.PhoneNumberType
  after delete
as
  insert into Person.PhoneNumberTypeHst
    (Action, ModifiedDate, SourceID, UserName)
  select N'delete' as Action
       , getdate() as ModifiedDate
       , PhoneNumberTypeID
       , CURRENT_USER as UserName
  from deleted;
go

----------------------

-- c) creating view
create view Person.PhoneNumberTypeView
  with encryption
as
  select * from Person.PhoneNumberType;
go
----------------------

-- d) checking the triggers
insert into Person.PhoneNumberTypeView
  (Name, ModifiedDate)
  values (N'Insert test', getdate());

update Person.PhoneNumberTypeView
  set Name = N'Update test'
  where Name = N'Insert test';

delete
  from Person.PhoneNumberTypeView
  where Name = N'Update test';


select * from Person.PhoneNumberTypeView
select * from Person.PhoneNumberTypeHst;
----------------------
