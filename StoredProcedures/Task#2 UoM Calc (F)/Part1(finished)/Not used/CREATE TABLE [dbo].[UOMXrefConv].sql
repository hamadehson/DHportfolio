USE [TriadPurchaseRequest]
GO

/****** Object:  Table [dbo].[UOMXrefConv]    Script Date: 11/8/2018 2:04:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UOMXrefConv](
	[stdUOMid] [int] NOT NULL,
	[stdUOMCode] [nchar](10) NOT NULL,
	[AltUOMid] [int] NOT NULL,
	[AltUOMCode] [nchar](10) NOT NULL,
	[AltUOMDesc] [nchar](10) NOT NULL,
	[AltUOMConv] [numeric](10, 3) NOT NULL,
	[ProjectID] [nchar](10) NOT NULL
) ON [PRIMARY]
GO


