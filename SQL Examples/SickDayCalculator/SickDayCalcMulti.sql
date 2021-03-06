

ALTER PROCEDURE [dbo].[SickDayAccrualMulti]

as
set nocount on;

/* Description: Outputs a report for all employee sick hours. Uses SickdayAccrual_2 for calculations */
/* 6/7/2019 dhamadeh - Initial Creation */

/* Declare Variables/Tables */
Declare @userid nvarchar(50) = dbo.getcurrentuser()
Declare @EmployeeId float

IF OBJECT_ID(N'tempdb..#tempmulti', N'U') IS NOT NULL 
drop table #tempmulti
create table #tempmulti
(
 EmployeeId float
,FirstName nvarchar(50)
,LastName nvarchar(50)
)

/* Start Procedure */
Delete from TriadPurchaseRequest.dbo.SickDayTotals
where userid = @userid

insert into #tempmulti (EmployeeId, FirstName, LastName)
select 
EmployeeId, 
FirstName, 
LastName
FROM [timeclockplus].[dbo].[EmployeeList]
where Department = 'HOURLY'
and [Dateleft] is null
and EmployeeId not in (117)




declare CalcHoursMulti cursor static
for		
	SELECT
	EmployeeId 
	FROM #tempmulti
	order by EmployeeId

open CalcHoursMulti

fetch next from CalcHoursMulti into @EmployeeId 

while @@FETCH_STATUS = 0

Begin

	Exec [SickDayAccrual_2] @Empid = @EmployeeId, @check = 1


fetch next from CalcHoursMulti into @EmployeeId 
End

close CalcHoursMulti
deallocate CalcHoursMulti


/* Update Names */
update SickDayTotals
set FirstName = #tempmulti.FirstName, LastName = #tempmulti.LastName
from #tempmulti
where userid = @userid
and sickdaytotals.employeeId = #tempmulti.EmployeeId


/* Get Data */
select
[EmployeeId]
,[FirstName]
,[LastName]
,[TotalHours]
,[ContributedHours]
,[LastYearEarnedHours]
,[EarnedHours]
,[UsedHours]
,[CumHours] 'RemainingHours'
from SickDayTotals
where userid = @userid
and EmployeeId not in (117)
order by LastName