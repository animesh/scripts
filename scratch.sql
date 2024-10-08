#https://medium.com/@mail2asimmanna/a-beautiful-sql-question-from-my-business-analyst-interview-8d46e1adbb3c
WITH x AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY date ASC) AS rnk
FROM attendance
WHERE present=1),
y AS (
SELECT *,DATE_ADD (date, INTERVAL -rnk DAY) AS grouped
FROM *),
Z AS (
SELECT id, date, COUNT(grouped) OVER(PARTITION BY id,grouped) AS cnt
FROM y)»
a AS (
SELECT *,RANK() OVER(ORDER BY cnt DESC) AS rn
FROM Z)
SELECT DISTINCT(id)
FROM a
WHERE rn=1;
