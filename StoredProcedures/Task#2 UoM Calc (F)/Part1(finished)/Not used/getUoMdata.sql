USE [TriadPurchaseRequest]
GO
/****** Object:  StoredProcedure [dbo].[getUoMdata]    Script Date: 10/31/2018 12:52:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Hamadeh
-- Create date: 10/30/2018
-- Status:		In Progress
-- Description:	Finds conversion rate for selected UoM
-- =============================================

--ALTER PROCEDURE [dbo].[getUoMdata]

--	-- parameters for the stored procedure here
--	@stduom nvarchar(20) = 'Gallon',
--	@altuom nvarchar(20) = 'Quart',
--	@conversrate float

--AS
-------------------------------------------------------------------------
	-- parameters for the stored procedure here
--	declare @stduom nvarchar(20) = 'Ounce'
--	declare @altuom nvarchar(20) = 'Gallon'
--	declare @conversrate float


--SELECT	@conversrate = Conver

--FROM	[TriadPurchaseRequest].[dbo].[UoMConver]

--WHERE	StdUoM = @stduom
--and		AltUoM = @altuom

--select @conversrate 'Conversion Rate'
--------------------------------------------------------------------------

--ALTER procedure [dbo].[getUoMdata]


	DECLARE @JobNumber int

--AS
	
	SELECT	JobNumber
	FROM [TriadPurchaseRequest].[dbo].[PurchaseRequestHeader]
	WHERE JobNumber = @JobNumber
	--UNION

	




