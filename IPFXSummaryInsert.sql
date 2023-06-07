WITH aggdata as (
select 
	id,
	[year],
	[month],
	[day],
	[hour],
	maxval,
	lag(maxval, 1, 0) over (partition by id, [year], [month], [day] order by id, [year], [month], [day], [hour]) prevmaxval,
	maxval - lag(maxval, 1, 0) over (partition by id, [year], [month], [day] order by id, [year], [month], [day], [hour]) as Diff
from
	[ipfx].[dbo].vwMax
),
livedata as (select sum (Qext) agents, sum(TTT)/sum(Ans) avgtalktime, sum(TQT)/sum(Ans) avgwaittime, sum(QC) queuing from
(
select DISTINCT qd.id Q, qd.lastupdate Qdt, qd.extensionsloggedin Qext, qd.answercount Ans, qd.totaltalktime TTT, qd.totalqueuetimeforansweredcalls TQT, qd.queueingcount QC
from [ipfx].[dbo].[QueueData] qd 
	INNER JOIN (select id, max(lastupdate) latest
	from [ipfx].[dbo].[QueueData]
	group by id) AS lastQrec
	ON qd.id = lastQrec.id AND qd.lastupdate = lastQrec.latest
) AS queues),
queuetotals as (
select
	id,
	sum(diff) queuetotal
	from
	(select 
		id,
		[year],
		[month],
		[day],
		[hour],
		maxval,
		lag(maxval, 1, 0) over (partition by id, [year], [month], [day] order by id, [year], [month], [day], [hour]) prevmaxval,
		maxval - lag(maxval, 1, 0) over (partition by id, [year], [month], [day] order by id, [year], [month], [day], [hour]) as Diff
	from
		[ipfx].[dbo].vwMax) as queues
where [year] = DATEPART(YEAR, GETDATE()) 
and [month] = DATEPART(MONTH, GETDATE()) 
and [day] = DATEPART(DAY, GETDATE())
group by id)

INSERT INTO [ipfx].[dbo].[Summary]( year, month, day, hour, minute, agentcount, avgduration, avgwait, currentqueue, answersthishour, totalanswercount, totaltoday, confirmationtotal, clearingtotal, adjustmenttotal, accommodationtotal, advregtotal, admnewtotal, admcurtotal)
SELECT DISTINCT
	DATEPART(YEAR, GETDATE()) [year],
	DATEPART(MONTH, GETDATE()) [month],
	DATEPART(DAY, GETDATE()) [day],
	DATEPART(HOUR, GETDATE()) [hour],
	DATEPART(MINUTE, GETDATE()) [minute],
	(select agents from livedata) as agents,
	(select avgtalktime from livedata) as avgtalktime,
	(select avgwaittime from livedata) as avgwait,
	(select queuing from livedata) as currentqueuelength,

	(select
		sum(Diff) diff
	from 
	(select 
		id,
		[year],
		[month],
		[day],
		[hour],
		maxval,
		lag(maxval, 1, 0) over (partition by id, [year], [month], [day] order by id, [year], [month], [day], [hour]) prevmaxval,
		maxval - lag(maxval, 1, 0) over (partition by id, [year], [month], [day] order by id, [year], [month], [day], [hour]) as Diff
	from
		[ipfx].[dbo].vwMax
	) as qcalls
	where [year] = DATEPART(YEAR, GETDATE()) 
	and [month] = DATEPART(MONTH, GETDATE()) 
	and [day] = DATEPART(DAY, GETDATE())
	and [hour] = DATEPART(HOUR, GETDATE())
	group by [year], [month], [day], [hour]
	) as callsthishour,

	(select sum(diff) from aggdata) Total,
	(select sum(diff) from aggdata 
	where[year] = DATEPART(YEAR, GETDATE()) 
	and [month] = DATEPART(MONTH, GETDATE()) 
	and [day] = DATEPART(DAY, GETDATE())) Totaltoday,
	ISNULL((select queuetotal from queuetotals where id = '69157'), 0) Confirmationtotal,
	ISNULL((select queuetotal from queuetotals where id = '69158'), 0) Clearingtotal,
	ISNULL((select queuetotal from queuetotals where id = '69159'), 0) Adjustmenttotal,
	ISNULL((select queuetotal from queuetotals where id = '69962'), 0) Accommodationtotal,
	ISNULL((select queuetotal from queuetotals where id = '69170'), 0) AdvRegtotal,
	ISNULL((select queuetotal from queuetotals where id = '66400'), 0) NewAdmissionstotal,
	ISNULL((select queuetotal from queuetotals where id = '66401'), 0) CurrentAdmissionstotal
FROM
	[ipfx].[dbo].[QueueData]                           
--where 
	