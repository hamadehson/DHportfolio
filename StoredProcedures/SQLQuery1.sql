USE [chieftain]
GO
/****** Object:  StoredProcedure [dbo].[getCleanUpFiles]    Script Date: 4/5/2021 12:22:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[getCleanUpFiles]

@PartNum as nvarchar(20)
,@Rev as nvarchar(10)
,@check as int

as 

/* debug */

----declare @PartNum as nvarchar(20) = '54780002'
----Declare @Rev as nvarchar(20) = '0001'
----declare @check as int = 1

/* debug */

if @check = 1
	Begin
		select PartNum
		,DwgRev
		from part
		join bom on part.PartId = bom.PartID
		join bomvehicle on bom.bomid = BOMVehicle.BOMId
		where partnum = @PartNum
		and DwgRev = @Rev
		and vehicleid in (62,57,59,50,63,54,71,72,76)
	End
Else
	Begin
		select PartNum
		,Rev
		from part
		join bom on part.PartId = bom.PartID
		join bomvehicle on bom.bomid = BOMVehicle.BOMId
		where partnum = @PartNum
		and rev = @Rev
		and vehicleid in (62,57,59,50,63,54,71,72,76)
	End

	