MATCH (s:Student) - [r:ENROLLED_IN {status: 'C'} ] -> (p:Program)
WITH *, r.conclusion_year - r.enroll_year AS duration
RETURN duration, avg(r.final_average)
ORDER BY duration