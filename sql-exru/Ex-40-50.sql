### 41. For each maker who has models at least in one of the tables PC, Laptop, or Printer, determine the maximum price for his products.
Output: maker; if there are NULL values among the prices for the products of a given maker, display NULL for this maker, otherwise, the maximum price.
  SELECT maker,
  CASE 
    WHEN COUNT(price) < COUNT(*) THEN NULL
    ELSE MAX(price)
  END AS m_price
FROM (
  SELECT p.maker, pc.price
  FROM Product p
  JOIN PC pc ON p.model = pc.model

  UNION ALL

  SELECT p.maker, l.price
  FROM Product p
  JOIN Laptop l ON p.model = l.model

  UNION ALL

  SELECT p.maker, pr.price
  FROM Product p
  JOIN Printer pr ON p.model = pr.model
) AS combined
GROUP BY maker;
 ________________________________________________________________
  ### 42. Find the names of ships sunk at battles, along with the names of the corresponding battles.
Select ship, battle from outcomes where result='sunk'
______________________________________________________________
### 43. Get the battles that occurred in years when no ships were launched into water.
SELECT name FROM battles WHERE DATEPART(year, date) NOT IN (
  SELECT launched FROM ships WHERE launched IS NOT NULL)
____________________________________________________________
### 44. Find all ship names beginning with the letter R
SELECT name FROM ships WHERE name LIKE 'R%'
UNION
SELECT ship AS name FROM outcomes WHERE ship LIKE 'R%';
________________________________________________________________
### 45. Find all ship names consisting of three or more words (e.g., King George V).
Consider the words in ship names to be separated by single spaces, and the ship names to have no leading or trailing spaces.
SELECT name FROM ships WHERE name LIKE '% % %'
UNION
SELECT ship AS name FROM outcomes WHERE ship LIKE '% % %';
---% matches any number of characters. '%' + space + '%' + space + '%' means: at least two spaces anywhere in the name.
____________________________________________________________
### 46. For each ship that participated in the Battle of Guadalcanal, get its name, displacement, and the number of guns.
Select o.ship, c.displacement, c.numGuns FROM Outcomes o Left JOIN Ships s ON o.ship = s.name LEFT JOIN classes c ON s.class = c.class OR o.ship = c.class 
WHERE o.battle = 'Guadalcanal';
OR
SELECT DISTINCT o.ship,
       COALESCE(c1.displacement, c2.displacement) AS displacement,
       COALESCE(c1.numGuns, c2.numGuns) AS numGuns
FROM outcomes o
FULL OUTER JOIN ships s ON o.ship = s.name
FULL OUTER JOIN classes c1 ON s.class = c1.class
FULL OUTER JOIN classes c2 ON o.ship = c2.class
WHERE o.battle = 'Guadalcanal';
  ___________________________________________________________
### 47. Find the countries that have lost all their ships in battles.
_____________________________________________________________________
### 48. Find the ship classes having at least one ship sunk in battles.
SELECT class FROM classes WHERE class IN (
    SELECT class 
    FROM (
        -- Case 1: Normal ships (name + class)
        SELECT s.name AS ship, c.class AS class
        FROM classes c
        JOIN ships s ON c.class = s.class
        
        UNION
        
        -- Case 2: Outcomes where ship name = class name
        SELECT o.ship AS ship, c.class AS class
        FROM classes c
        JOIN outcomes o ON o.ship = c.class
    ) a
    JOIN outcomes op ON op.ship = a.ship
    WHERE op.result = 'sunk'
);
  ________________________________________________________________
### 49. Find the names of the ships having a gun caliber of 16 inches (including ships in the Outcomes table).
SELECT s.name FROM Ships s JOIN Classes c ON s.class = c.class
WHERE c.bore = 16
UNION
SELECT o.ship FROM Outcomes o LEFT JOIN Ships s ON o.ship = s.name
JOIN Classes c ON o.ship = c.class WHERE c.bore = 16;
  ________________________________________________________________
### 50. Find the battles in which Kongo-class ships from the Ships table were engaged.
SELECT DISTINCT o.battle FROM Outcomes o
WHERE o.ship IN (SELECT name FROM Ships WHERE class = 'Kongo');
