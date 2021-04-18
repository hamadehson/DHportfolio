
Create Procedure [dbo].[UpdateListAltUoM]

@Altid int,
@AltNewDesc nvarchar(20),
@AltNewConv Numeric (10,3)

AS


/*	null = no adds
	1 = add None
	2 = add All
	3 = add Select One */

/* ===================================== */
/* start debug items */
/* ===================================== */

--declare @Altid int = 1
--declare @AltNewDesc nvarchar(20) = 'Ounces'
--declare @AltNewConv numeric (10,3) = 29.375

/* ===================================== */
/* end debug items */
/* ===================================== */


Update	TriadPurchaseRequest.dbo.UOMXrefConv
  Set	[AltUOMConv] = @AltNewConv,
		[AltUOMDesc] = @AltNewDesc
  WHERE [AltUOMid] = @Altid
