/*INSERT INTO [ipfx].[dbo].[Summary](answersthishour)*/
SELECT
	/*DATEPART(HOUR, [prev].lastupdate) AS [hour],
	DATEPART(HOUR, [current].lastupdate) AS [chour],
	[current].answercount, */
   ISNULL([current].answercount, 0) - [prev].answercount AS callsThisHour
FROM
   [ipfx].[dbo].[QueueData]       AS [prev]
LEFT JOIN
   [ipfx].[dbo].[QueueData]       AS [current]
      ON [current].answercount = (SELECT MIN(answercount) FROM [ipfx].[dbo].[QueueData] WHERE answercount > [prev].answercount)
WHERE
	DATEPART(DAY, [current].lastupdate) = DATEPART(DAY, GETDATE())