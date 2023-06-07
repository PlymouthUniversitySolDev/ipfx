select
	id,
	[description],
	sum(diff) queuetotal
	from
	(select 
		id,
		[description],
		[year],
		[month],
		[day],
		[hour],
		maxval,
		lag(maxval, 1, 0) over (partition by id, [description], [year], [month], [day] order by id, [description], [year], [month], [day], [hour]) prevmaxval,
		maxval - lag(maxval, 1, 0) over (partition by id, [description], [year], [month], [day] order by id, [description], [year], [month], [day], [hour]) as Diff
	from
		vwMax) as queues
where [year] = DATEPART(YEAR, GETDATE()) 
and [month] = DATEPART(MONTH, GETDATE()) 
and [day] = DATEPART(DAY, GETDATE())
group by id, [description]
;