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
	vwMax
;