

/* Description: Calculates the # of sick hours employees have available based on total number of full work weeks for each year (35+ work hours per week = 1 sick hour). Years start on 4/1/---- */
/* 12/16/2020 dhamadeh - Initial Creation, Rev bump from sickdayaccrual for multiple large changes to stored procedure */
/* 12/21/2020 dhamadeh - Holiday,Vacation & familydeath costcodes now count towards work hours. Covid hours now removed from work hours. */

ALTER PROCEDURE [dbo].[SickDayAccrual_2]

@EmpId float,
@Check int = 0

as
set nocount on;


/* Being Debug */

----declare @EmpId float = 12
----declare @check int = 0

/* End Debug */


/* Declare & Set Variables/tables */
IF OBJECT_ID(N'tempdb..#temp1', N'U') IS NOT NULL 
drop table #temp1
create table #temp1
(
 [Week] date
,[EarnedHours] numeric(7,3)
,[UsedHours] numeric(7,3)
,[CumHours] numeric(7,3)
)


Declare @CurrentDate datetime = getdate()
Declare @CurrentYearStartDate datetime = (select cast(Year(getdate()) as nvarchar(50)) + '-04-01')

if @CurrentDate < @CurrentYearStartDate
	begin
		set @CurrentYearStartDate = DATEADD(year, -1, @CurrentYearStartDate)
	End

Declare @CurrentYearEndDate datetime = DATEADD(DAY, 364, @CurrentYearStartDate)
Declare @LastYearStartDate datetime = DATEADD(year, -1, @CurrentYearStartDate)
Declare @LastYearEndDate datetime = DATEADD(DAY, -1, @CurrentYearStartDate)
Declare @WeekStartDate datetime = 0
Declare @WeekEndDate datetime = 0
declare @TimeIn datetime
declare @TimeOut datetime
declare @emphire date = (select DateHire from [timeclockplus].[dbo].[EmployeeList] where EmployeeId = @EmpId)

Declare @EarnedSickHours numeric(7,3) = 0
Declare @UsedSickHours numeric(7,3) = 0
Declare @RemainingSickHours numeric(7,3) = 0
declare @CumWorkHours numeric(7,3) = 0
declare @ContributedWorkHours numeric(7,3) = 0
declare @WeekTotal numeric(7,3) = 0
declare @LastYearTotalSickHours numeric(7,3) = 0
declare @TotalWorkHours numeric(7,3) = 0
declare @TotalEarnedHours numeric(7,3) = 0
declare @TotalUsedHours numeric(7,3) = 0
declare @VacationHours numeric(7,3) = 0

declare @RecordId nvarchar(20)
declare @CostCode nvarchar(50)
declare @userid nvarchar(50) = dbo.getcurrentuser()


/* Set initial Last Year Week Dates */
set @weekstartdate = @lastyearstartdate
set @WeekStartDate = DATEADD(day, -1, @WeekStartDate)

While (select DATENAME(dw, @weekstartdate)) <> 'Monday'
	Begin
		set @weekstartdate = DATEADD(Day, 1, @weekstartdate)
	End
set @WeekEndDate = DATEADD(day, 6, @weekstartdate)


/* Calculate Previous Year Sick Hours */
declare LYCalcHours cursor static
for		
	SELECT
	[RecordId]
	,[TimeIn]
	,[TimeOut]
	,CostCode
	FROM [timeclockplus].[dbo].[EmployeeHours]
	where [TimeIn] >= @LastYearStartDate
	and [TimeOut] < @LastYearEndDate
	and EmployeeId = @EmpId

open LYCalcHours

fetch next from LYCalcHours into @RecordId, @TimeIn, @TimeOut, @CostCode
while @@FETCH_STATUS = 0
Begin


/* Calculate End of Week Hours */
If @TimeIn > @WeekEndDate
Begin
	set @RemainingSickHours = @RemainingSickHours - @UsedSickHours
	set @TotalWorkHours = @TotalWorkHours + @WeekTotal

	If (@WeekTotal >= 35.00) and (@EmpHire < @TimeIn)
	Begin
		/* Calculate End of Week Totals (Increase In Sick Hours)*/
		set @CumWorkHours = @CumWorkHours + @WeekTotal
		if @WeekTotal < 40
			set @ContributedWorkHours = @ContributedWorkHours + @WeekTotal
		Else
			set @ContributedWorkHours = @ContributedWorkHours + 40


		If ((@RemainingSickHours < 40) and (@RemainingSickHours > 39))
			begin
				set @EarnedSickHours = @EarnedSickHours + 1
				set @RemainingSickHours = 40
			End
		Else if (@RemainingSickHours < 39)
			begin
				set @EarnedSickHours = @EarnedSickHours + 1
				set @RemainingSickHours = @RemainingSickHours + 1
			End
		Else
			Begin
				set @RemainingSickHours = 40
			End


		/* Reset Week Values & Start next week*/
		insert into #temp1 ([Week],[EarnedHours],[UsedHours],[CumHours])
		Values ((convert(date,@WeekStartDate)), 1, @UsedSickHours, @RemainingSickHours)

		set @WeekTotal = 0
		set @UsedSickHours = 0
		set @WeekEndDate = DATEADD(Day, 7, @WeekEndDate)
		set @WeekStartDate = DATEADD(Day, 7, @WeekStartDate)
		end
	Else
		Begin
			/* Calculate End of Week Totals (No Increase In Sick Hours)*/
			set @CumWorkHours = @CumWorkHours + @WeekTotal

			/* Reset Week Values & Start next week*/
			insert into #temp1 ([Week],[EarnedHours],[UsedHours],[CumHours])
			Values ((convert(date,@WeekStartDate)), 0, @UsedSickHours, @RemainingSickHours)

			set @WeekTotal = 0
			set @UsedSickHours = 0
			set @WeekEndDate = DATEADD(Day, 7, @WeekEndDate)
			set @WeekStartDate = DATEADD(Day, 7, @WeekStartDate)
		End
	End



/* Calculate Daily Hours */
if @CostCode like '%6191 - PAID SICK LEAVE COVID-19\%'
	Begin
		Print 'Covide Sick Leave Time: ' + cast(@TimeIn as nvarchar(50)) + ' - ' + cast(@TimeOut as nvarchar(50)) + ' Emp#: ' + cast(@empid as nvarchar(10))
	end
Else if @CostCode = '011 - NON-OCCUP. ILLNESS OR INJURY'
	Begin
		set @UsedSickHours = @usedsickhours + ((Select timesheetminutes from [timeclockplus].[dbo].[EmployeeHours] where RecordId = @RecordId)/ 60.000)
		if @UsedSickHours is null
			set @UsedSickHours = 0
	End
Else
	Begin
		if @CostCode = '014 - VACATION' or @CostCode = '017 - HOLIDAY' or @CostCode = '047 - VACATION' or @CostCode = '012 - DEATH IN IMMEDIATE FAMILY'
			Begin
				set @VacationHours = ((Select timesheetminutes from [timeclockplus].[dbo].[EmployeeHours] where RecordId = @RecordId)/ 60.000)
				if @VacationHours is null
					Begin
						set @VacationHours = 0
					End
				set @WeekTotal = @WeekTotal + @VacationHours
				Set @VacationHours = 0
			End
		set @WeekTotal = @WeekTotal + (datediff(second, @TimeIn, @TimeOut) / 3600.0)
	End

fetch next from LYCalcHours into @RecordId, @TimeIn, @TimeOut, @CostCode
end

close LYCalcHours
deallocate LYCalcHours

/* Save Last Year Hours & reset values */
if @RemainingSickHours < 0
	begin
		set @LastYearTotalSickHours = 0
		set @RemainingSickHours = 0
	End
Else
	set @LastYearTotalSickHours = @RemainingSickHours





/* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/* Calculate Current Year Sick Hours */
declare CalcHours cursor static
for		
	SELECT
	[RecordId]
	,[TimeIn]
	,[TimeOut]
	,CostCode
	FROM [timeclockplus].[dbo].[EmployeeHours]
	where [TimeIn] >= @CurrentYearStartDate
	and [TimeOut] < @CurrentYearEndDate
	and EmployeeId = @EmpId

open CalcHours

fetch next from CalcHours into @RecordId, @TimeIn, @TimeOut, @CostCode
while @@FETCH_STATUS = 0
Begin


/* Calculate End of Week Hours */
If @TimeIn > @WeekEndDate
Begin
	set @RemainingSickHours = @RemainingSickHours - @UsedSickHours
	set @TotalWorkHours = @TotalWorkHours + @WeekTotal

	If (@WeekTotal >= 35.00) and (@EmpHire < @TimeIn)
	Begin
		/* Calculate End of Week Totals (Increase In Sick Hours)*/
		set @CumWorkHours = @CumWorkHours + @WeekTotal
		if @WeekTotal < 40
			set @ContributedWorkHours = @ContributedWorkHours + @WeekTotal
		Else
			set @ContributedWorkHours = @ContributedWorkHours + 40


		If ((@RemainingSickHours < 80) and (@RemainingSickHours > 79))
			begin
				set @EarnedSickHours = @EarnedSickHours + 1
				set @RemainingSickHours = 80
			End
		Else if (@RemainingSickHours < 79)
			begin
				set @EarnedSickHours = @EarnedSickHours + 1
				set @RemainingSickHours = @RemainingSickHours + 1
			End
		Else
			Begin
				set @RemainingSickHours = 80
			End


		/* Reset Week Values & Start next week*/
		insert into #temp1 ([Week],[EarnedHours],[UsedHours],[CumHours])
		Values ((convert(date,@WeekStartDate)), 1, @UsedSickHours, @RemainingSickHours)

		set @WeekTotal = 0
		set @UsedSickHours = 0
		set @WeekEndDate = DATEADD(Day, 7, @WeekEndDate)
		set @WeekStartDate = DATEADD(Day, 7, @WeekStartDate)
	end
	Else
		Begin
			/* Calculate End of Week Totals (No Increase In Sick Hours)*/
			set @CumWorkHours = @CumWorkHours + @WeekTotal

			/* Reset Week Values & Start next week*/
			insert into #temp1 ([Week],[EarnedHours],[UsedHours],[CumHours])
			Values ((convert(date,@WeekStartDate)), 0, @UsedSickHours, @RemainingSickHours)

			set @WeekTotal = 0
			set @UsedSickHours = 0
			set @WeekEndDate = DATEADD(Day, 7, @WeekEndDate)
			set @WeekStartDate = DATEADD(Day, 7, @WeekStartDate)
		End
	End

/* Calculate Daily Hours */
if @CostCode like '%6191 - PAID SICK LEAVE COVID-19\%'
	Begin
		Print 'Covide Sick Leave Time: ' + cast(@TimeIn as nvarchar(50)) + ' - ' + cast(@TimeOut as nvarchar(50)) + ' Emp#: ' + cast(@empid as nvarchar(10))
	end
Else if @CostCode = '011 - NON-OCCUP. ILLNESS OR INJURY'
	Begin
		set @UsedSickHours = @usedsickhours + ((Select timesheetminutes from [timeclockplus].[dbo].[EmployeeHours] where RecordId = @RecordId)/ 60.000)
		if @UsedSickHours is null
			set @UsedSickHours = 0
	End
Else
	Begin
		if @CostCode = '014 - VACATION' or @CostCode = '017 - HOLIDAY' or @CostCode = '047 - VACATION' or @CostCode = '012 - DEATH IN IMMEDIATE FAMILY'
			Begin
				set @VacationHours = ((Select timesheetminutes from [timeclockplus].[dbo].[EmployeeHours] where RecordId = @RecordId)/ 60.000)
				if @VacationHours is null
					Begin
						set @VacationHours = 0
					End
				set @WeekTotal = @WeekTotal + @VacationHours
				Set @VacationHours = 0
			End
		set @WeekTotal = @WeekTotal + (datediff(second, @TimeIn, @TimeOut) / 3600.0)
	End

fetch next from CalcHours into @RecordId, @TimeIn, @TimeOut, @CostCode
End

close CalcHours
deallocate CalcHours



/* Final Calculations */
set @TotalEarnedHours = (select SUM(EarnedHours) from #temp1 where [#temp1].[Week] > @CurrentYearStartDate)
set @TotalUsedHours = (select SUM(UsedHours) from #temp1 where [#temp1].[Week] > @CurrentYearStartDate)


/* Select Final Calculations */
if @check = 1
	Begin
		/* Multiple Employee Listing */
		insert into SickDayTotals([userid], [EmployeeId], [TotalHours], [ContributedHours], [lastyearearnedhours], [EarnedHours], [UsedHours], [CumHours])
		values (@userid, @EmpId, @TotalWorkHours, @ContributedWorkHours, @LastYearTotalSickHours, @TotalEarnedHours, @TotalUsedHours, @RemainingSickHours)
	end
Else
	Begin
		/* Single Employee Listing */
		select * from #temp1
		order by [Week]
	End