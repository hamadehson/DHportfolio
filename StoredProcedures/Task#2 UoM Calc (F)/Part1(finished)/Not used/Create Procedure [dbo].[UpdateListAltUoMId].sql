USE [TriadPurchaseRequest]
GO
/****** Object:  StoredProcedure [dbo].[UpdateListAltUoMId]    Script Date: 11/8/2018 12:11:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[UpdateListAltUoMId]

@ProdId int,
@PartId int,
@StdM int,
@AltM int

AS


/*	null = no adds
	1 = add None
	2 = add All
	3 = add Select One */

/* ===================================== */
/* start debug items */
/* ===================================== */

--Declare @ProdId int = 25
--Declare @PartId int = 54782527
--Declare @StdM int = 3
--Declare @AltM int = 10

/* ===================================== */
/* end debug items */
/* ===================================== */


Update	TriadPurchaseRequest.dbo.UOMXrefID
  Set	[Std] = @StdM,
		[Alt] = @AltM
  WHERE [ProdID] = @ProdId and
		[PartID] = @PartId
