
CREATE TABLE [dbo].[UOMXrefConv](
	[PartNum] [nvarchar](50) NOT NULL,
	[stdUOMid] [int] NOT NULL,
	[stdUOMCode] [nvarchar](10) NOT NULL,
	[AltUOMid] [int] IDENTITY(1,1) NOT NULL,
	[AltUOMCode] [nvarchar](10) NOT NULL,
	[AltUOMDesc] [nvarchar](20) NOT NULL,
	[AltUOMConv] [numeric](10, 3) NOT NULL,
	[ProjectID] [nvarchar](20) NOT NULL
) ON [PRIMARY]
GO


