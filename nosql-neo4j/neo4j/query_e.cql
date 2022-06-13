MATCH (s:Student) -[:ENROLLED_IN]-> (p:Program)
WITH *

MATCH (s) -[:CANDIDATE_TO]-> (p)
WITH s AS student, p AS program, count(p) AS applications_per_student

WHERE applications_per_student > 1
RETURN student.id, program.code, program.designation, applications_per_student
ORDER BY applications_per_student DESC