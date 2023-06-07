select
	[year],
	[month],
	[day],
	[hour],
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
;