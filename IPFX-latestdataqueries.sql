/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  [id]
      ,[lastupdate]
      ,[description]
      ,[status]
      ,[answercount]
      ,[abandonedcount]
      ,[othercount]
      ,[gradeofservice]
      ,[extensionsloggedin]
      ,[queueingcount]
      ,[longestqueuetime]
      ,[maximumcallsqueued]
      ,[maximumqueuetime]
      ,[totalqueuetimeforansweredcalls]
      ,[totaltalktime]
      ,[warningcount]
      ,[warningtime]
      ,[alertcount]
      ,[alerttime]
      ,[agents]
      ,[queues_ID]
  FROM [ipfx].[dbo].[QueueData]
  ORDER BY lastupdate desc;

select DISTINCT qd.id, qd.lastupdate, qd.extensionsloggedin
from [ipfx].[dbo].[QueueData] qd 
	INNER JOIN (select id, max(lastupdate) latest
	from [ipfx].[dbo].[QueueData]
	group by id) AS lastQrec
	ON qd.id = lastQrec.id AND qd.lastupdate = lastQrec.latest
;

select sum (Qext) from
(
select DISTINCT qd.id Q, qd.lastupdate Qdt, qd.extensionsloggedin Qext
from [ipfx].[dbo].[QueueData] qd 
	INNER JOIN (select id, max(lastupdate) latest
	from [ipfx].[dbo].[QueueData]
	group by id) AS lastQrec
	ON qd.id = lastQrec.id AND qd.lastupdate = lastQrec.latest
) AS queues;

CREATE VIEW [dbo].liveupdate AS(
select sum (Qext) agents, sum(TTT)/sum(Ans) avgtalktime, sum(TQT)/sum(Ans) avgwaittime, sum(QC) queuing from
(
select DISTINCT qd.id Q, qd.lastupdate Qdt, qd.extensionsloggedin Qext, qd.answercount Ans, qd.totaltalktime TTT, qd.totalqueuetimeforansweredcalls TQT, qd.queueingcount QC
from [ipfx].[dbo].[QueueData] qd 
	INNER JOIN (select id, max(lastupdate) latest
	from [ipfx].[dbo].[QueueData]
	group by id) AS lastQrec
	ON qd.id = lastQrec.id AND qd.lastupdate = lastQrec.latest
) AS queues);


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
)
select sum (Qext) agents, sum(TTT)/sum(Ans) avgtalktime, sum(TQT)/sum(Ans) avgwaittime, sum(QC) queuing from
(
select DISTINCT qd.id Q, qd.lastupdate Qdt, qd.extensionsloggedin Qext, qd.answercount Ans, qd.totaltalktime TTT, qd.totalqueuetimeforansweredcalls TQT, qd.queueingcount QC
from [ipfx].[dbo].[QueueData] qd 
	INNER JOIN (select id, max(lastupdate) latest
	from [ipfx].[dbo].[QueueData]
	group by id) AS lastQrec
	ON qd.id = lastQrec.id AND qd.lastupdate = lastQrec.latest
) AS queues;