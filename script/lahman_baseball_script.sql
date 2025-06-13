-- ## Lahman Baseball Database Exercise
-- this data has been made available [online](http://www.seanlahman.com/baseball-archive/statistics/) by Sean Lahman
-- A data dictionary is included with the files for this project.

-- ### Use SQL queries to find answers to the *Initial Questions*. If time permits, choose one (or more) of the *Open-Ended Questions*. Toward the end of the bootcamp, we will revisit this data if time allows to combine SQL, Excel Power Pivot, and/or Python to answer more of the *Open-Ended Questions*.



-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 
-- A - 1871 through 2016
SELECT MIN(year) AS first_year,
	   MAX(year) AS last_year
FROM homegames


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
-- shortest player is Eddie Gaedel and his height was 43" and played 52 total games for Baltimore

SELECT playerid, namefirst AS first_name, namelast AS last_name, height, SUM(g_all) AS career_games_played, franchid
FROM appearances
	INNER JOIN people USING(playerid)
	INNER JOIN teams USING(teamid)
GROUP BY playerid, namefirst, namelast, height, franchid
ORDER BY height ASC
LIMIT 1



-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order
-- by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- ANSWER: David Price has the highest career earnings that came from the Vanderbilt University Baseball program with $81 Million career earnings


--- Vandy Player CTE
WITH vandy_players AS (
SELECT DISTINCT playerid
FROM collegeplaying
	INNER JOIN schools USING(schoolid)
WHERE schoolname = 'Vanderbilt University')
----------------------------------------------------
SELECT namefirst AS first_name, namelast AS last_name, SUM(salary)::text::numeric::money AS total_salary
FROM vandy_players
	LEFT JOIN salaries USING(playerid)
	LEFT JOIN people USING(playerid)
WHERE salary IS NOT NULL
GROUP BY namefirst, namelast
ORDER BY total_salary DESC




-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
-- Determine the number of putouts made by each of these three groups in 2016.
SELECT CASE 
	WHEN pos = 'SS' OR pos= '1B' OR pos= '2B' OR pos = '3B' THEN 'Infield'
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
	END AS position_categories,
	SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position_categories
ORDER BY total_putouts DESC;

   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

-- TRENDS: Strikeouts were the highest in the 60's and 70's when they were above 2 strikeouts per game. Home Runs have steadily increased each deacde from the 1920's

-- PITCHING
  SELECT CASE
			WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
			WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN yearid BETWEEN 1980 and 1989 THEN '1980s'
			WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
			END AS decade,
			ROUND(SUM(so)::numeric/SUM(g)::numeric, 2) AS strikeouts_per_game
FROM pitching
GROUP BY decade
ORDER BY decade DESC NULLS LAST;

-- BATTING

SELECT CASE
			WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
			WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN yearid BETWEEN 1980 and 1989 THEN '1980s'
			WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN yearid BETWEEN 2010 AND 2019 THEN '2010s'
			END AS decade,
			ROUND(SUM(hr)::numeric/SUM(g)::numeric, 2) AS home_runs_per_game
			-- If i wanted the number as a percent:    ROUND(SUM(hr*1.0)::numeric/SUM(g)::numeric * 100, 2)||'%' AS hr_per_gp
FROM batting
GROUP BY decade
ORDER BY decade DESC NULLS LAST;





-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
-- Consider only players who attempted _at least_ 20 stolen bases.

-- ANSWER: CHRIS OWINGS HAD THE HIGHEST STEAL SUCCESS RATE AT 91.3% IN 2016. 

SELECT namefirst, namelast, ROUND(sb::numeric / (cs + sb) * 100, 2)||'%' AS success_rate
FROM batting
	INNER JOIN people USING(playerid)
WHERE yearid = 2016
AND (sb+cs) >= 20
AND sb IS NOT NULL AND cs IS NOT NULL AND (sb + cs) > 0
ORDER BY success_rate DESC





-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an 
-- unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also 
-- won the world series? What percentage of the time?

-- MOST WINS WIHTOUT WOLRD SERIES WIN: Seattle Mariners had the most wins in a sesaon without winning a wolrd series. They did it in 2001 and had 116 wins and won 71.6% of their games
SELECT yearid, franchid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
ORDER BY w DESC

--------------- with win % added in
SELECT yearid, franchid, w, wswin, ROUND((w::numeric/g) * 100, 2)||'%' AS win_percentage
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
ORDER BY w DESC


-- LEAST WINS WITH A WORLD SERIES WIN: The Los Angeles Dodgers had the least amount of wins (63) to win a world series. They did it in 1981
SELECT yearid, franchid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
ORDER BY w ASC


-- Excluding the year 1981, the team with the least amount of wins to win a World Series was the 2006 St. Louis Cardinals who won the WS with only 83 wins. 1981 had to be excluded because players were on strike for the majority of the season. 
-- 1/3 of that 1981 season was canceled and therefor had less games and less wins to show for it
SELECT yearid, franchid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
AND yearid <> 1981
AND wswin = 'Y'
ORDER BY w ASC


-- How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- ANSWER: STUMPED
SELECT yearid, franchid, w, wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
-- AND wswin = 'Y'
ORDER BY yearid ASC, w DESC



WITH most_wins AS (
SELECT yearid, MAX(w)
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
GROUP BY yearid
ORDER BY yearid ASC)

SELECT *
FROM most_wins



-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). 
-- Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

-- ANSWER: TOP 5 ATTENDANCE
-- Los Angeles Dodgers with the highest with 45,719
SELECT park_name, team,(attendance/games) AS avg_attendance 
FROM homegames
	INNER JOIN parks USING(park)
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5



-- ANSWER: BOTTOM 5 ATTENDANCE
-- Tampa Bay with the lowest at 15,878
SELECT park_name, team,(attendance/games) AS avg_attendance 
FROM homegames
	INNER JOIN parks USING(park)
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance ASC
LIMIT 5



-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

--ANSWER: DAVEY JOHNSON AND JIM LEYLAND

-- CTE 1
WITH nl_winners AS(
SELECT *
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid = 'NL'),
-- CTE 2
al_winners AS(
SELECT *
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid ='AL'),
-- CTE 3 
al_and_nl_winners AS(
SELECT *
FROM awardsmanagers
WHERE playerid IN (SELECT playerid
				   FROM awardsmanagers
				   WHERE awardid = 'TSN Manager of the Year'
				   AND lgid ='AL')
	AND playerid IN (SELECT playerid
				     FROM awardsmanagers
					 WHERE awardid = 'TSN Manager of the Year'
				   	 AND lgid = 'NL')
	AND awardid = 'TSN Manager of the Year')
SELECT DISTINCT(namefirst), namelast, name, al_and_nl_winners.yearid, al_and_nl_winners.lgid
FROM al_and_nl_winners
	LEFT JOIN people USING (playerid)
	LEFT JOIN managers USING (playerid, yearid)
	LEFT JOIN teams ON managers.teamid=teams.teamid
	WHERE teams.yearid>1900
ORDER BY yearid DESC;



-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
-- Report the players' first and last names and the number of home runs they hit in 2016.




WITH player_hr AS (SELECT playerid, yearid, SUM(hr) AS total_hr
FROM batting
GROUP BY playerid, yearid),
career_high AS (SELECT playerid, MAX(total_hr) AS highest_hr
FROM player_hr
GROUP BY playerid),
player_yr AS(SELECT playerid,COUNT(DISTINCT yearid) AS num_yr
FROM batting
GROUP BY playerid),
hr_2016 AS (SELECT playerid, SUM(hr) AS hr_2016
FROM batting
WHERE yearid=2016
GROUP BY playerid)
SELECT p.namefirst, p.namelast, h.hr_2016
FROM hr_2016 AS h
JOIN career_high AS c
ON h.playerid=c.playerid AND h.hr_2016=c.highest_hr
JOIN player_yr AS py
ON h.playerid=py.playerid AND py.num_yr >=10
JOIN people AS p
ON h.playerid=p.playerid
WHERE h.hr_2016 >0



-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, 
-- so you may want to look on a year-by-year basis.

-- STUMPED
WITH team_salaries AS (
SELECT teamid, SUM(salary)::text::numeric::money AS team_salary
FROM salaries
WHERE yearid BETWEEN 2000 AND 2016
GROUP BY teamid
ORDER BY team_salary DESC)

SELECT teamid, team_salary, w
FROM team_salaries
	INNER JOIN teams USING(teamid)




-- 12. In this question, you will explore the connection between number of wins and attendance.
     -- Does there appear to be any correlation between attendance at home games and number of wins? 
     -- Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

SELECT *
FROM homegames
	INNER JOIN teams USING()
	 


-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. 
-- First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?