SELECT
	[prev].answercount,
	[current].answercount as [current],
	DATEPART(HOUR, [prev].lastupdate) AS [hour],
	DATEPART(HOUR, [current].lastupdate) AS [chour],
	ISNULL([current].answercount, 0) + [prev].answercount AS totalCalls
FROM
   [ipfx].[dbo].[QueueData]       AS [prev]
LEFT JOIN
   [ipfx].[dbo].[QueueData]       AS [current]
      ON [current].answercount = (SELECT 
										MIN(answercount) 
										FROM 
											[ipfx].[dbo].[QueueData] 
										WHERE 	
											DATEPART(DAY, [prev].lastupdate) = DATEPART(DAY, GETDATE() - 1) AND
											DATEPART(DAY, [current].lastupdate) = DATEPART(DAY, GETDATE()))
WHERE
	DATEPART(DAY, [current].lastupdate) = DATEPART(DAY, GETDATE())
	
ORDER BY [prev].answercount;