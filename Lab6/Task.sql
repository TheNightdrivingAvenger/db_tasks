--- TASK (variant) #6 ---
use AdventureWorks2012
go

----------------------

create procedure HumanResources.CountGenderByCity @genderSymbols nvarchar(20)
as
  declare @pivotQuery nvarchar(1024);
  set @pivotQuery =
N'select City, ' + @genderSymbols +
N'
    from (
      select addr.City as City, emp.Gender as Gender from
        HumanResources.Employee as emp
        join Person.BusinessEntityAddress as bea
          on emp.BusinessEntityID = bea.BusinessEntityID
        join Person.Address as addr
          on bea.AddressID = addr.AddressID
    )
    as srcTable
  pivot (
    count(srcTable.Gender)
    for srcTable.Gender in (' + @genderSymbols + N')
  )
  as pivotTable';

  exec(@pivotQuery);
go

----------------------
exec HumanResources.CountGenderByCity N'[F],[M]'
go
