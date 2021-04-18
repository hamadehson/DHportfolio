USE [TriadPurchaseRequest]
GO

/****** Object:  Table [dbo].[UOMXrefID]    Script Date: 11/8/2018 2:03:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UOMXrefID](
	[ProdID] [int] NOT NULL,
	[PartID] [nvarchar](50) NOT NULL,
	[Std] [int] NOT NULL,
	[Alt] [int] NOT NULL
) ON [PRIMARY]
GO


