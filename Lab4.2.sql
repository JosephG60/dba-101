-- #2 How may seats are available 
set nocount on 

SELECT [SeatNumber]
      ,[CustomerNumber]
      ,[DateSold]
  FROM [AdventureWorks10].[dbo].[Seat]
  WHERE CustomerNumber is null and DateSold is null