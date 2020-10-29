--- TASK (variant) #6 ---
use AdventureWorks2012
go

-- Creating a function for order sum
create function Sales.CalculateOrderCost (@SalesOrderID int)
returns money
as
begin
  declare @totalSum money;
  select @totalSum = (SubTotal + TaxAmt + Freight)
           from Sales.SalesOrderHeader
           where SalesOrderID = @SalesOrderID;

  return @totalSum;
end;
go
----------------------

-- Creating an inline function for getting order details
create function Production.GetOrderDetail (@WorkOrderId int)
returns table
as
return (
  select wor.* from 
    Production.WorkOrderRouting as wor
    where wor.WorkOrderID = @WorkOrderId
);
go
----------------------

-- Calling the functions
select Sales.CalculateOrderCost(43659) as OrderTotal

select * from Production.WorkOrder as wo
  cross apply Production.GetOrderDetail(wo.WorkOrderID);

select * from Production.WorkOrder as wo
  outer apply Production.GetOrderDetail(wo.WorkOrderID);
----------------------

-- Creating a multistatement function for getting order details
create function Production.GetOrderDetailMS (@WorkOrderId int)
returns @orderDetails table (
  WorkOrderID int not null
, ProductID int not null
, OperationSequence smallint not null
, LocationID smallint not null
, ScheduledStartDate datetime not null
, ScheduledEndDate datetime not null
, ActualStartDate datetime null
, ActualEndDate datetime null
, ActualResourceHrs decimal(9, 4) null
, PlannedCost money not null
, ActualCost money null
, ModifiedDate datetime not null
)
as
begin
  insert @orderDetails
    select wor.* from 
      Production.WorkOrderRouting as wor
      where wor.WorkOrderID = @WorkOrderId;
    return;

end;
go

-- Calling the functions again and comaring the results
select * from Production.WorkOrder as wo
  cross apply Production.GetOrderDetail(wo.WorkOrderID);

select * from Production.WorkOrder as wo
  cross apply Production.GetOrderDetailMS(wo.WorkOrderID);


select * from Production.WorkOrder as wo
  outer apply Production.GetOrderDetail(wo.WorkOrderID);

select * from Production.WorkOrder as wo
  outer apply Production.GetOrderDetailMS(wo.WorkOrderID);
----------------------
