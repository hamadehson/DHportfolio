USE [TriadPurchaseRequest]
GO

/****** Object:  Table [dbo].[UoMXrefId]    Script Date: 11/2/2018 10:52:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UoMXrefId](
	[ProdID] [int] NOT NULL,
	[PartID] [int] NOT NULL,
	[Std] [numeric](10, 3) NOT NULL,
	[Alt] [numeric](10, 3) NOT NULL
) ON [PRIMARY]
GO


