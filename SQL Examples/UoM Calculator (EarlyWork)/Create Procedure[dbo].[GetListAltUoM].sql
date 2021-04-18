
create Procedure[dbo].[GetListAltUoM]

@Projectid nvarchar(20),
--@StdUoMid int,
@PartNum nvarchar(50)

AS


/*	null = no adds
	1 = add None
	2 = add All
	3 = add Select One */

/* ===================================== */
/* start debug items */
/* ===================================== */

--declare @PartNum nvarchar(50) = 54780003
--declare @Projectid nvarchar(20) = 'The Truck'
--declare @StdUoMid int = 1

/* ===================================== */
/* end debug items */
/* ===================================== */


SELECT	[AltUOMid]
		,[AltUOMCode]
		,[AltUOMDesc]
		,[AltUOMConv] 
  FROM	TriadPurchaseRequest.dbo.UOMXrefConv
  WHERE		[ProjectID] = @Projectid
		--and [stdUOMid] = @StdUoMid
		and [PartNum] = @PartNum	 


	
