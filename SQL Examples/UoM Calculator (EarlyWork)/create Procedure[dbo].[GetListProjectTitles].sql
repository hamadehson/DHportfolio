
create Procedure[dbo].[GetListProjectTitles]
@type int = null

AS


/*	null = no adds
	1 = add None
	2 = add All
	3 = add Select One */

--------declare @type int = null

SELECT [ProjectID]
      ,[ProjectTitle] 
  FROM triadsecurity.dbo.Projects
union 
	select 0, '- None -'
	where @type = 1
	union 
	select 0, '- All -'
	where @type = 2
	union 
	select 0, '- Select One -'
	where @type = 3

	Order by ProjectTitle

