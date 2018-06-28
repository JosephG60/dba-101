-- #3  With a manual transaction 

begin transaction 

update AdventureWorks10.dbo.seat 
set CustomerNumber = 2
where SeatNumber = 8
and DateSold is null

-- commit
-- rollback


-- review the seat I selected, now have everyone else try.
-- who has the seat, what problem does this create

SELECT [SeatNumber]
      ,[CustomerNumber]
      ,[DateSold]
  FROM [AdventureWorks10].[dbo].[Seat] 
  WHERE DateSold is null