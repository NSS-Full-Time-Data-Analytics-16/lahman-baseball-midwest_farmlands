SELECT *
FROM people;
--Question 1
--What range of years for baseball games played does the provided database cover?
SELECT MIN(year) AS start_year, MAX(year) AS end_year
FROM homegames;
-- range of years:1871 to 2016

--Question 3
--Find all players in the database who played at Vanderbilt University.
---schoolid='vandy'
---create a list showing each player’s first and last names--
-- as well as the total salary they earned in the major leagues
---the total salary they earned in the major leagues---
--Sort this list in descending order by the total salary earned
---Which Vanderbilt player earned the most money in the majors?
--Inner Query
SELECT DISTINCT playerid
FROM collegeplaying
WHERE schoolid='vandy';
--Nested Query
SELECT namefirst||' '||namelast AS name, SUM(salary::text::numeric::money) as total_salary
FROM people
INNER JOIN salaries 
USING(playerid)
WHERE playerid IN (SELECT DISTINCT playerid
FROM collegeplaying
WHERE schoolid='vandy')
GROUP BY namefirst||' '||namelast 
ORDER BY total_salary DESC
LIMIT 1
--David Price earned the most money in the majors with $81,851,296.00

-- Question 6
--Find the player who had the most success stealing bases in 2016
--where __success__ is measured as the percentage of stolen base attempts which are successful
--A stolen base attempt results either in a stolen base or being caught stealing
--Consider only players who attempted _at least_ 20 stolen bases.
--sb=stolen bases cs=caught stealing
SELECT namefirst||' '||namelast AS name,b.sb AS stolen_bases, b.cs AS caught_stealing, ROUND((1.0*b.sb/(b.sb +b.cs)) * 100,2)||'%' AS success_rate
FROM batting AS b
INNER JOIN people AS p
USING (playerid)
WHERE b.yearid=2016 AND
(b.sb +b.cs)>=20
ORDER BY success_rate DESC
LIMIT 1;
--Chris Owings had the most success stealing bases in 2016 (91.30%)--

---Question 9---
--Which managers have won the TSN Manager of the Year award in both the National League (NL) 
---and the American League (AL)?
--Give their full name and the teams that they were managing when they won the award.

--- Question 9 
WITH nl_winners AS(
SELECT *
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid = 'NL'),

al_winners AS(
SELECT *
FROM awardsmanagers
WHERE awardid = 'TSN Manager of the Year'
	AND lgid ='AL'),

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

--Question 10--
--Find all players who hit their career highest number of home runs in 2016
--Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.
WITH player_hr AS (SELECT playerid, yearid, SUM(hr) AS total_hr
FROM batting
GROUP BY playerid, yearid),
career_high AS (SELECT playerid, MAX(total_hr) AS highest_hr
FROM player_hr
GROUP BY playerid),
player_yr AS(SELECT playerid,COUNT(Distinct yearid) AS num_yr
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

