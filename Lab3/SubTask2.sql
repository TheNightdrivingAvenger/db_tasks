--- TASK (variant) #6 ---

use AdventureWorks2012
go

-- a) adding 'TotalGroupSales' and 'SalesYTD'; as well as 'RoundSales'
alter table dbo.Person
  add TotalGroupSales money null
    , SalesYTD money null
    , RoundSales as round(SalesYTD, 0);
----------------------

-- b) adding temp table
create table #Person (
  BusinessEntityID int          not null
, PersonType       nchar(2)     not null
-- I could use a workaround to create the type in the 'tempdb', but I saw no good reason to do it, so base bit instead of NameStyle
, NameStyle        bit          not null
, Title            nvarchar(8)  null
-- I could use a workaround to create the type in the 'tempdb', but I saw no good reason to do it, so base nvarchar(50) instead of Name
, FirstName        nvarchar(50) not null
, MiddleName       nvarchar(50) null
, LastName         nvarchar(50) not null
, Suffix           nvarchar(10) null
, EmailPromotion   int          not null
, ModifiedDate     datetime     not null
, TotalGroupSales  money        not null
, SalesYTD         money        not null
);
----------------------

-- c) filling the temp table
insert into #Person
select p.BusinessEntityID
     , p.PersonType
     , p.NameStyle      
     , p.Title          
     , p.FirstName      
     , p.MiddleName     
     , p.LastName       
     , p.Suffix         
     , p.EmailPromotion 
     , p.ModifiedDate   
     , p.TotalGroupSales
     , st.SalesYTD
  from dbo.Person as p
  join Person.BusinessEntityAddress as bea
    on p.BusinessEntityID = bea.BusinessEntityID
  join Person.Address as a
    on bea.AddressID = a.AddressID
  join Person.StateProvince as sp
    on a.StateProvinceID = sp.StateProvinceID
  join Sales.SalesTerritory as st
    on sp.CountryRegionCode = st.CountryRegionCode;

with SalesSum as (
  select st.[Group], sum(st.SalesYTD) as SSum
    from #Person as p
    join Person.BusinessEntityAddress as bea
      on p.BusinessEntityID = bea.BusinessEntityID
    join Person.Address as a
      on bea.AddressID = a.AddressID
    join Person.StateProvince as sp
      on a.StateProvinceID = sp.StateProvinceID
    join Sales.SalesTerritory as st
      on sp.CountryRegionCode = st.CountryRegionCode
    group by
      st.[Group]
)
update
  #Person
  set SalesYTD = SalesSum.SSum
  from SalesSum;
----------------------

-- d) deleting from Person where the 'EmailPromotion' is 2
delete
  from dbo.Person
  where EmailPromotion = 2;
----------------------

-- e) merge #Person -> dbo.Person
merge dbo.Person as tgt
  using #Person as src
    on tgt.BusinessEntityID = src.BusinessEntityID
  when matched then
    update
      set tgt.TotalGroupSales = src.TotalGroupSales
        , tgt.SalesYTD = src.SalesYTD
  when not matched by target then
    insert (
      BusinessEntityID
    , PersonType      
    , NameStyle       
    , Title           
    , FirstName       
    , MiddleName      
    , LastName        
    , Suffix          
    , EmailPromotion  
    , ModifiedDate    
    , TotalGroupSales 
    , SalesYTD)
    values (
      BusinessEntityID
    , PersonType      
    , NameStyle       
    , Title           
    , FirstName       
    , MiddleName      
    , LastName        
    , Suffix          
    , EmailPromotion  
    , ModifiedDate    
    , TotalGroupSales 
    , SalesYTD        
  )
  when not matched by source then
    delete;
----------------------
