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





