USE [TriadPurchaseRequest]
GO
/****** Object:  Table [dbo].[UoMConver]    Script Date: 10/31/2018 9:04:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UoMConver](
	[Conid] [int] NOT NULL,
	[StdUoM] [nvarchar](50) NOT NULL,
	[AltUoM] [nvarchar](50) NOT NULL,
	[Conver] [float] NOT NULL,
 CONSTRAINT [PK_UoMConver] PRIMARY KEY CLUSTERED 
(
	[Conid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
