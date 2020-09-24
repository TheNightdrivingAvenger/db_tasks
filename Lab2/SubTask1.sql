--- TASK (variant) #6 ---

use AdventureWorks2012;
go

-- the earliest start date in every department
select dep.Name, MIN(edh.StartDate) as StartDate
  from HumanResources.EmployeeDepartmentHistory as edh
  join HumanResources.Department as dep
    on dep.DepartmentID = edh.DepartmentID
  group by dep.Name
----------------------

-- stocker's shifts
select e.BusinessEntityId
     , e.JobTitle
     , case
         when s.Name = 'Day' then 1
         when s.Name = 'Evening' then 2
         when s.Name = 'Night' then 3
       else 0
       end
       as ShiftName
  from HumanResources.Employee as e
  join HumanResources.EmployeeDepartmentHistory as edh
    on edh.BusinessEntityID = e.BusinessEntityID
  join HumanResources.Shift s
    on edh.ShiftID = s.ShiftID
  where e.JobTitle = 'Stocker'
----------------------

-- all employees
select e.BusinessEntityId
     , replace(e.JobTitle, 'and', '&') as JobTitle
     , dep.Name as DepName
  from HumanResources.Employee as e
  join HumanResources.EmployeeDepartmentHistory as edh
    on edh.BusinessEntityID = e.BusinessEntityID
  join HumanResources.Department as dep
    on edh.DepartmentID = dep.DepartmentID
  where edh.EndDate is null
----------------------
