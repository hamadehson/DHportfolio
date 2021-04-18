USE [TriadPurchaseRequest]
GO
/****** Object:  StoredProcedure [dbo].[InsertListAltUoMId]    Script Date: 11/8/2018 12:26:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[InsertListAltUoMId]

@ProductId int,
@PartId int,
@NewStdId int,
@NewAltId int

AS


/*	null = no adds
	1 = add None
	2 = add All
	3 = add Select One */

/* ===================================== */
/* start debug items */
/* ===================================== */

--Declare @ProductId int = 25
--Declare @PartId int = 54782527
--Declare @NewStdUoM int = 3
--Declare @NewAltConv int = 10


/* ===================================== */
/* end debug items */
/* ===================================== */

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
