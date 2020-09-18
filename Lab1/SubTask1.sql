-- create db
create database NewDatabase
go
----------------------

--- add schemas
use NewDatabase
go
create schema sales
go

create schema persons
go
----------------------

--- create table
create table sales.Orders (OrderNum int null)
----------------------

--- backup the DB
declare @path nvarchar(256) = N'F:\newDB.bak'

backup database NewDatabase
  to
  disk = @path
go
----------------------

--- drop the DB
drop database NewDatabase
go
----------------------

--- restore the DB
restore database NewDatabase
  from
  disk = @path