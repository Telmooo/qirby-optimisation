MATCH (s:Student) -[:ENROLLED_IN]-> (p:Program)
WITH *

MATCH (s) -[:CANDIDATE_TO]-> (p)
WITH s AS student, p AS program, count(p) AS total_applications

WHERE total_applications > 1
RETURN student, program, total_applications
ORDER BY total_applications DESC