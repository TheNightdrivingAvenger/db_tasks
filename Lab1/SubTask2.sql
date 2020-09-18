--- TASK (variant) #6 ---

use AdventureWorks2012;
go

-- departments that start with 'F' and end with 'e'
select [DepartmentID], [Name] from HumanResources.Department
  where [Name] like 'F%e'
----------------------

-- average sick/vacation hours
select AVG(VacationHours) as AvgVacationHours, AVG(SickLeaveHours) as AvgSickHours from HumanResources.Employee
----------------------

-- employees older than 65 by now
declare @dtNow DateTime = GETDATE()
select BusinessEntityID, JobTitle, Gender, DATEDIFF(year, HireDate, @dtNow) as YearsWorked from HumanResources.Employee
  where DATEDIFF(year, BirthDate, @dtNow) > 65
----------------------