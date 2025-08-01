________________________________________________________________
### 30. Under the assumption that receipts of money (inc) and payouts (out) can be registered any number of times a day for each collection point [i.e. the code column is the primary key], display a table with one corresponding row for each operating date of each collection point.
Result set: point, date, total payout per day (out), total money intake per day (inc).
Missing values are considered to be NULL.
------
SELECT 
    COALESCE(i.point, o.point) AS point,
    COALESCE(i.date, o.date) AS date,
    o.total_out,
    i.total_inc
FROM
    (SELECT point, date, SUM(out) AS total_out FROM Outcome GROUP BY point, date) o
FULL OUTER JOIN
    (SELECT point, date, SUM(inc) AS total_inc FROM Income GROUP BY point, date) i
ON o.point = i.point AND o.date = i.date
________________________________________________________________

### 31. For ship classes with a gun caliber of 16 in. or more, display the class and the country.
Select class, country from Classes where bore >= 16  
____________________________________________________________
### 32. One of the characteristics of a ship is one-half the cube of the calibre of its main guns (mw).
Determine the average ship mw with an accuracy of two decimal places for each country having ships in the database.
WITH total AS (
  SELECT country, bore, name
  FROM Classes JOIN Ships ON Classes.class = Ships.class
  UNION
  SELECT country, bore, ship
  FROM Classes JOIN Outcomes ON Classes.class = Outcomes.ship
)
SELECT country, CAST(AVG(POWER(bore, 3) * 0.5) AS NUMERIC(10,2)) AS weight FROM total GROUP BY country;
________________________________________________________________
  ### 33. Get the ships sunk in the North Atlantic battle.
Result set: ship.
SELECT ship FROM Outcomes WHERE battle = 'North Atlantic' AND result = 'sunk';
________________________________________________________________
### 34. In accordance with the Washington Naval Treaty concluded in the beginning of 1922, it was prohibited to build battle ships with a displacement of more than 35 thousand tons.
Get the ships violating this treaty (only consider ships for which the year of launch is known).
List the names of the ships.
  --- Select s.name from ships s JOIN  Classes c ON s.class= c.class where c.type = 'bb' AND s.launched >= 1922 AND c.displacement > 35000 AND s.launched IS NOT NULL

  ________________________________________________________________________________________________________________________________
 ### 35. Find models in the Product table consisting either of digits only or Latin letters (A-Z, case insensitive) only.
Result set: model, type.
  SELECT model, type
FROM Product
WHERE model NOT LIKE '%[^0-9]%' 
   OR model NOT LIKE '%[^A-Za-z]%';
--%[^0-9]% means: the string contains at least one character that is not a digit (0–9). So NOT LIKE '%[^0-9]%' means: the string does not contain any non-digit characters → i.e., it contains digits only.1
This says: Return rows where model is made of only digits,
OR Return rows where model is made of only letters (A–Z, case-insensitive)
  ________________________________________________________________
 ### 36.List the names of lead ships in the database (including the Outcomes table).
 SELECT name FROM Ships WHERE name IN (SELECT class FROM Classes)
UNION
SELECT ship FROM Outcomes WHERE ship IN (SELECT class FROM Classes) AND ship NOT IN (SELECT name FROM Ships);
________________________________________________________________
### 37. Find classes for which only one ship exists in the database (including the Outcomes table).
  SELECT class FROM (SELECT class, name FROM Ships UNION ALL SELECT class, ship FROM Outcomes JOIN Classes ON ship = class) AS AllShips
GROUP BY class HAVING COUNT(DISTINCT name) = 1;
#### Why JOIN + UNION? JOIN gets class name for ships in Outcomes. UNION merges the two sources (ships from both tables). GROUP BY + HAVING helps count per class.
  ________________________________________________________________
### 38. Find countries that ever had classes of both battleships (‘bb’) and cruisers (‘bc’). 
 // A single row cannot have both 'bb' and 'bc' in the type column. :- Select country from Classes where type='bb' AND 'bc'
  Select country from Classes where type='bb' 
union 
Select country from Classes where type='bc' 
//This will just return a distinct list of countries that have battleships (type = 'bc') but it's redundant
  COREECT 
  Select country from Classes where type='bb' 
Intersect
Select country from Classes where type='bc' 
OR
SELECT country FROM Classes WHERE type IN ('bb', 'bc') GROUP BY country HAVING COUNT(DISTINCT type) = 2;

_________________________________________________________________
### 39. Find the ships that `survived for future battles`; that is, after being damaged in a battle, they participated in another one, which occurred later.
SELECT DISTINCT a.ship 
FROM (SELECT ship, result, date FROM outcomes JOIN battles ON outcomes.battle = battles.nameWHERE result = 'damaged') a
JOIN (SELECT ship, result, date FROM outcomes JOIN battles ON outcomes.battle = battles.name) b
ON a.ship = b.shipAND b.date > a.date
⚔️ Strategy Overview
Filter all battles where ships were damaged (we’ll call this Set A).
Collect all battles of all ships (we’ll call this Set B).
Join A and B on:
Same ship name.
B’s battle date is after A’s battle date.
If a match is found, the ship survived to fight again.
Use DISTINCT to avoid listing a ship multiple times.
📌 Key Concepts Used
JOIN with condition: Used to compare battles of the same ship across time.
Date Comparison: Ensures we only look at later battles.
DISTINCT: Avoids duplicates if a ship appears in many future battles.
  ________________________________________________________________
### 40. Get the makers who produce only one product type and more than one model. Output: maker, type.

SELECT maker, MIN(type) AS type
FROM Product
GROUP BY maker
HAVING COUNT(DISTINCT type) = 1 AND COUNT(DISTINCT model) > 1;

WITH OneTypeMakers AS (
    SELECT maker
    FROM Product
    GROUP BY maker
    HAVING COUNT(DISTINCT type) = 1 AND COUNT(model) > 1
)

SELECT p.maker, p.type
FROM Product p
JOIN OneTypeMakers o ON p.maker = o.maker
GROUP BY p.maker, p.type;
  ________________________________________________________________
