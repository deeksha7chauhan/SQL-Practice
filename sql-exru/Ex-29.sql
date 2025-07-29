SELECT 
  COALESCE(i.point, o.point) AS point,
  COALESCE(i.date, o.date) AS date,
  i.inc AS income,
  o.out AS expense FROM 
  Income_o i
FULL OUTER JOIN
Outcome_o o ON i.point = o.point AND i.date=o.date
