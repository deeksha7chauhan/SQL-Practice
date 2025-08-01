###51. Find the names of the ships with the largest number of guns among all ships having the same displacement (including ships in the Outcomes table).

 ________________________________________________________________
### 52. Determine the names of all ships in the Ships table that can be a Japanese battleship having at least nine main guns with a caliber
 of less than 19 inches and a displacement of not more than 65 000 tons.
SELECT DISTINCT name FROM Ships s JOIN Classes c ON s.class = c.class WHERE 
  (country = 'Japan' OR country IS NULL)
  AND (type = 'bb' OR type IS NULL)
  AND (numGuns >= 9 OR numGuns IS NULL)
  AND (bore < 19 OR bore IS NULL)
  AND (displacement <= 65000 OR displacement IS NULL);
  ________________________________________________________________
### 53. With a precision of two decimal places, determine the average number of guns for the battleship classes.
SELECT CAST(AVG(numGuns*1.0) AS NUMERIC(6,2)) FROM classes WHERE type = 'bb'
--- CAST(<expression> AS <data type>)

| Component                   | Purpose                                            |
| --------------------------- | -------------------------------------------------- |
| `numGuns * 1.0`             | Ensures float division for accurate average        |
| `AVG(...)`                  | Computes average of gun count                      |
| `CAST(... AS NUMERIC(6,2))` | Forces final output to be exactly 2 decimal places |
| Final result                | Returns `9.67` instead of `9.670000` or `9`        |

  ________________________________________________________________ 
### 54. With a precision of two decimal places, determine the average number of guns for all battleships (including the ones in the Outcomes table).
WITH a AS (
    -- PART 1: From real ships
    SELECT name AS ship, numGuns
    FROM classes c
    JOIN ships s ON s.class = c.class
    WHERE c.type = 'bb'

    UNION

    -- PART 2: From Outcomes directly when 'ship' field is actually a class name
    SELECT ship AS ship, numGuns
    FROM outcomes o
    JOIN classes c ON o.ship = c.class
    WHERE c.type = 'bb'
)
-- Final SELECT: Average of numGuns from both sources
SELECT CAST(AVG(numGuns * 1.0) AS NUMERIC(6,2)) FROM a;
________________________________________________________________
### 55. For each class, determine the year the first ship of this class was launched. If the lead ship’s year of launch is not known, get the minimum year of launch for the ships of this class.
Result set: class, year.
SELECT c.class, COALESCE( MIN(CASE WHEN s.name = c.class THEN s.launched END), MIN(s.launched)) AS year FROM Classes c LEFT JOIN Ships s ON s.class = c.class GROUP BY c.class;
  ________________________________________________________________
### 56. For each class, find out the number of ships of this class that were sunk in battles.
Result set: class, number of ships sunk.
SELECT class, SUM(sunks) AS sunks 
FROM (
	SELECT class, 
	       SUM(CASE result WHEN 'sunk' THEN 1 ELSE 0 END) AS sunks 
	FROM Classes c 
	LEFT JOIN Outcomes o ON c.class = o.ship
	WHERE class NOT IN (SELECT name FROM Ships) 
	GROUP BY class

	UNION ALL

	SELECT class, 
	       SUM(CASE result WHEN 'sunk' THEN 1 ELSE 0 END) AS sunks 
	FROM Ships s 
	LEFT JOIN Outcomes o ON s.name = o.ship
	GROUP BY class
) AS x
GROUP BY class;

Split the Problem into Two Parts
 - Part A: Count sunk ships where class name is used directly in Outcomes.ship
 - Part B: Count sunk ships using Ships.name → Outcomes.ship mapping
Build Two Subqueries
 - Join Classes with Outcomes for class-name ships (exclude those in Ships)
 - Join Ships with Outcomes for normal ships
Use CASE WHEN result = 'sunk' to count only sunk ships.
Combine Both with UNION ALL
Group by class and SUM the sunk counts

  ________________________________________________________________
 ________________________________________________________________
  ________________________________________________________________
  ________________________________________________________________
