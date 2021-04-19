
/* Description: Imports new vehicle data trees via Excel sheets into DB for use. Builds the same tree in DB. */

/***** Directions for use *****/
/*
1. Check Excel sheet to be imported for any column name errors
2. Import Excel Sheet into desired database (Imported sheet must be named "Import")
3. Update Manual Variables in Stored procedure
4. Run Procedure
5. Delete the imported table
*/

declare @bomid int
declare @TableId int
declare @desc nvarchar(255)
declare @parent int
declare @qty numeric(7,3)
declare @partnum nvarchar(25)
declare @rev nvarchar(10)
declare @partclass int
declare @partid int
declare @const int
declare @ParentBomid int
declare @LastBomid int
declare @BVBomid int
declare @IABomid int
declare @DesignStatus nvarchar(5)
declare @LineLoc nvarchar(50)
declare @torque nvarchar(150)
declare @date datetime = getdate()
declare @userid as nvarchar(50) = dbo.getcurrentuser()

/********************** Variables to manually set ************************/

declare @xiabom int = 793091
declare @ern int = '15625'
declare @pdt int = 2
declare @Partition int = 6
declare @subpartition int = 27
declare @BOMrelStatus int = 6
declare @PurchaseResponsible int  = 2
declare @vehicleid int = 78

/* ---- Start Debug ----- */

----select * from PDT
----select * from [Partition]
----select * from SubPartition
------select * from ReleaseStatus
------select * from PurchResponsible
------select * from Vehicle

/* ----- End Debug ----- */



IF OBJECT_ID(N'tempdb..#temp1', N'U') IS NOT NULL 
drop table #temp1
create table #temp1
( 
tableid int
,[desc] nvarchar(255)
,BomDesc nvarchar(255)
,parent int
,qty numeric(7,3)
,partnum nvarchar(25)
,rev nvarchar(10)
,dwg nvarchar(10)
,partclass int
,partid int
,const int 
,DesStat nvarchar(5)
,LineLoc nvarchar(50)
,Torque nvarchar(150)
)

IF OBJECT_ID(N'tempdb..#temp2', N'U') IS NOT NULL 
drop table #temp2
create table #temp2
(Tableid int
,Bomid int)

IF OBJECT_ID(N'tempdb..#temp3', N'U') IS NOT NULL 
drop table #temp3
create table #temp3
(partid int
,lineloc nvarchar(50)
,Torque nvarchar(150)
,BomDesc nvarchar(255))

IF OBJECT_ID(N'tempdb..#temp4', N'U') IS NOT NULL 
drop table #temp4
create table #temp4
( 
tableid int
,[desc] nvarchar(255)
,parent int
,qty int
,partnum nvarchar(25)
,rev nvarchar(10)
,dwg nvarchar(10)
,partclass int
,partid int
,const int 
,DesStat nvarchar(5)
)

IF OBJECT_ID(N'tempdb..#temp5', N'U') IS NOT NULL 
drop table #temp5





/* Update Dwg Rev, Partid, lineloc, torque */
print 'Start Dwg rev, partid, lineloc,torque updates'

update Import$
set [dwg rev] = (
select max([DwgRev])
from Part
where Import$.Partnum = part.PartNum
and Import$.rev = part.Rev
)

update Import$
set [dwg rev] = '0001'
where [dwg rev] is null

insert into #temp1
select 
ID
,PART_DESCRIPTION
,null
,PARENT
,Quantity
,Partnum
,rev
,[dwg rev]
,partclass
,null
,[const type]
,[v100DS]
,null
,null
from Import$


update #temp1
set #temp1.partid = part.PartId
from Part
where #temp1.partnum = part.PartNum
and #temp1.rev = part.Rev
and #temp1.dwg = part.DwgRev

insert into #temp3 (partid, lineloc, torque, BomDesc)
select partid, LineLocation, Torque, BOMDesc
from bom
join BOMVehicle on bom.BOMID = bomvehicle.BOMId
where VehicleId = 59

update #temp1
set #temp1.LineLoc= #temp3.lineloc, #temp1.Torque = #temp3.Torque, #temp1.BomDesc = #temp3.BomDesc
from #temp3
where #temp1.PartID = #temp3.partid
and #temp1.partid <> 15476
and #temp3.lineloc is not null


/* Update Part table release status */
print 'Update Part Release status'

update Part 
set ReleaseStatusId = 6, DwgReleaseStatusId = 6, ERNNumber =  @ern, ERNDate = @date
where PartId in (select PartId from #temp1)
and partid <> 15476


/* ------------------------------------------------------------------------------------------------------ */
/* Insert BOM  Lines*/
print 'Insert new BOM Lines'

declare PopulateBom cursor static
for		
	select 
	tableid
	,BomDesc
	,PARENT
	,qty
	,Partnum
	,rev
	,partclass
	,partid
	,const
	,DesStat
	,LineLoc
	,Torque
	from #temp1
	order by tableid

open PopulateBom
fetch next from PopulateBom into @tableid, @desc, @parent, @qty, @partnum, @rev, @partclass, @partid, @const, @DesignStatus, @lineloc, @torque

while @@FETCH_STATUS = 0

Begin

	if @parent = 0
		begin

			set @LastBomid = 24058

			insert into #temp2
			select 1, @LastBomid

		End
	Else
		begin 

			set @ParentBomid = (select bomid from #temp2 where Tableid = @parent)

			insert into bom
			([PartID]
           ,[Qty]
		   ,BOMDesc
           ,[ParentBOMID]
           ,[PartitionID]
           ,[SubPartitionID]
           ,[PartClassId]
           ,[IssueDate]
           ,[BOMRelStatId]
           ,[CreatedBy]
           ,[CreatedDate]
		   ,alternateConst
		   ,IABOMId
		   ,BOMPurchResp
		   ,altConstTypeID
		   ,ERNNumber
		   ,ERNDate
		   ,PDTId
		   ,V100DesignStatus
		   ,LineLocation
		   ,Torque)
			select @partid, @qty, @desc, @ParentBomid, @Partition, @subpartition, @partclass, @date, @BOMrelStatus, @userid, @date, @const, @xiabom, @PurchaseResponsible, @const, @ern, @date, @pdt, @DesignStatus, @LineLoc, @torque

			set @LastBomid = (select top 1 bomid from bom order by bomid desc)

			insert into #temp2
			select @TableId, @LastBomid

		end



fetch next from PopulateBom into @tableid, @desc, @parent, @qty, @partnum, @rev, @partclass, @partid, @const, @DesignStatus, @lineloc, @torque
End

close PopulateBom
deallocate PopulateBom


/* Update Bomvehicle */
print 'Updating Bomvehicle'

declare PopulateBomVeh cursor static
for		
	select 
	bomid
	from #temp2
	where Tableid <> 0
	and bomid <> 24058
	order by bomid


open PopulateBomVeh
fetch next from PopulateBomVeh into @BVBomid

while @@FETCH_STATUS = 0

Begin

	insert into BOMVehicle
	(BOMId, VehicleId, TorqueApplied, TorqueAppliedBy, TorqueAppliedOn)
	select @bvbomid, @vehicleid, 0 , null, null

fetch next from PopulateBomVeh into @BVBomid
End

close PopulateBomVeh
deallocate PopulateBomVeh


/* Delete Orphans */
print 'Delete Orphan BOM Lines'

insert into #temp4
select 
ID
,PART_DESCRIPTION
,PARENT
,Quantity
,Partnum
,rev
,[dwg rev]
,partclass
,null
,[const type]
,[v100DS]
from Import$

update #temp4
set #temp4.partid = part.PartId
from Part
where #temp4.partnum = part.PartNum
and #temp4.rev = part.Rev
and #temp4.dwg = part.DwgRev

select bomid 
into #temp5
from bom
where partid in (select partid from #temp4 where partid <> 15476)
and IABOMId is null

delete from BOMVehicle 
where bomid in (select bomid from #temp5)
and BOMId <> @xiabom

delete from bom
where partid in (select partid from #temp4 where partid <> 15476)
and IABOMId is null
and BOMId <> @xiabom




/* Debug/testing */

----select * from BOMVehicle
----where bomid in (select BOMId from bom where IABOMId = 791641)


----select * from bom where ERNNumber = '999999'
----and IABOMId = 793091


----select * from #temp1 where partid is null

----select * from part where PartNum = '61950129'
