
Create Procedure [dbo].[CheckAltUoM]

 @PartNum nvarchar(50)
,@StdUOMId int
,@AltUOMNewName nvarchar(10)
,@check int output
AS

--Declare @check int = 1

/* =================================check==== */
/* start debug items */
/* ===================================== */

--Declare @PartNum nvarchar(50) = 54782527
--Declare @StdUOMId int = 1
--Declare @AltUOMNewName nvarchar(10) = 'oz'
--Declare @check int = 1

/* ===================================== */
/* end debug items */
/* ===================================== */

If EXISTS (Select * from TriadPurchaseRequest.dbo.UOMXrefConv
				Where	PartNum = @PartNum
					and stdUOMid = @StdUOMId
					and AltUOMCode = @AltUOMNewName
					)
					Begin
						SET @check = 2
						--Select @check
					END
Else
--Select @check
Set @check = 1