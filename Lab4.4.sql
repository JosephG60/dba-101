
  
-- What is a unit of work (a transaction)

-- #4 Now run as a transaction
declare @CustomerNumber  int
declare @SeatNumber int
declare @ccapproval int

select @CustomerNumber = 8  -- Group number 
select @SeatNumber = 2

set nocount on 

  begin tran


  -- select the seat 
  update AdventureWorks10.dbo.seat 
	set CustomerNumber = @CustomerNumber
	where SeatNumber = @SeatNumber
	and DateSold is null
 
 -- tenatively mark the seat as sold 
	update AdventureWorks10.dbo.seat 
	set DateSold = getdate()
	where SeatNumber = @SeatNumber
	and customerNumber =  @CustomerNumber 
	and DateSold is null  -- so you can't purchase a seat you have already purchased

	select @@rowcount as NumRowsChanged

--simulate credit card apporval 
	 waitfor delay '00:00:10' --- ten seconds

--select @ccapproval = -1 --- failed 
  select @ccapproval = 100 --- succeeded  

	if @ccapproval <= 0 
		rollback  -- credit card transaction failed. Rollback transaction.
	else	
		commit  --  credit card was approved. Complete transaction.


