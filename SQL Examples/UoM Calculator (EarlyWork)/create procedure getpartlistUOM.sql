
/* tmorrison 11/1/18 - initial cretion */
Create procedure getpartlistUOM

@projectid int 

as

set nocount on;

/* ===================================== */
/* start debug items */
/* ===================================== */

----declare @projectid int  = 25

/* ===================================== */
/* end debug items */
/* ===================================== */

declare @dbname nvarchar(50)
declare @sqlstring nvarchar(500)

set @dbname = (select dbname from  triadsecurity.dbo.projects where projectid = @projectid)


set @sqlstring = 
'select
partid
,partnum
,dwgrev
,partdesc
,uom.UOMId
,uom.UnitOfMeasure
from ' + @dbname +'.dbo.part
join ' + @dbname +'.dbo.uom on part.UOMId = uom.uomid'


exec(@sqlstring)
