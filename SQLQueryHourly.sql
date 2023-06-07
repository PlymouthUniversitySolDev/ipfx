SELECT 
	id,
	lastupdate,
	answercount,
	DATEPART(HOUR, lastupdate) AS [hour]
FROM [ipfx].[dbo].[QueueData]
WHERE
	DATEPART(DAY, lastupdate) = DATEPART(DAY, GETDATE()) AND
	(DATEPART(HOUR, lastupdate) = DATEPART(HOUR, GETDATE()) OR
	DATEPART(HOUR, lastupdate) = DATEPART(HOUR, GETDATE()) -1);
