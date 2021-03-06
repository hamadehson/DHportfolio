

Create Procedure[dbo].[InsertListAltUoM]

@StdNewId int,
@StdNewUOM nvarchar(10),
@AltNewUOM nvarchar(10),
@AltNewDesc nvarchar(20),
@AltNewConv Numeric (10,3),
@ProjectId nvarchar(20),

/* Variables for UoMXrefID table below */

@ProductId int,
@PartId nvarchar(20),
@NewStdId int


AS

Declare @NewAltId int

/*	null = no adds
	1 = add None
	2 = add All
	3 = add Select One */

/* ===================================== */
/* start debug items */
/* ===================================== */

--Declare @StdNewId int = 1
--Declare @StdNewUOM nvarchar(10) = 'mL'
--Declare @AltNewUOM nvarchar(10) = 'oz'
--Declare @AltNewDesc nvarchar(20) = 'Ounces'
--Declare @AltNewConv Numeric (10,3) = 29.375
--Declare @ProjectId nvarchar(20) = 'The Truck'

--Declare @ProductId int = 25
--Declare @PartId int = 54782527
--Declare @NewStdId int = 3
--Declare @NewAltId int

/* ===================================== */
/* end debug items */
/* ===================================== */

If NOT EXISTS (Select * from TriadPurchaseRequest.dbo.UOMXrefConv
				Where	stdUOMid = @StdNewId
					and	stdUOMCode = @StdNewUOM
					and	AltUOMCode = @AltNewUOM
					and AltUOMDesc = @AltNewDesc
					and AltUOMConv = @AltNewConv
					and ProjectID = @ProjectId
					)
					Begin
						Insert Into	TriadPurchaseRequest.dbo.UOMXrefConv (PartNum, stdUOMid, stdUOMCode, AltUOMCode, AltUOMDesc, AltUOMConv, ProjectID)
						Values		(@PartId, @StdNewId, @StdNewUOM, @AltNewUOM, @AltNewDesc, @AltNewConv, @ProjectId)
					END

Set @NewAltId = (Select Top 1 AltUOMid from TriadPurchaseRequest.dbo.UOMXrefConv order by AltUOMid DESC)

If NOT EXISTS (Select * from TriadPurchaseRequest.dbo.UoMXrefId
				Where	ProdID = @ProductId
					and	PartID = @PartId
					and	Std = @NewStdId
					and	Alt = @NewAltId
					)
					Begin
						Insert Into	TriadPurchaseRequest.dbo.UOMXrefID(ProdID, PartID, Std, Alt)
						Values		(@ProductId, @PartId, @NewStdId, @NewAltId)
					END
