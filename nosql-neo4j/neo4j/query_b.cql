MATCH (:Student) - [r:ENROLLED_IN ] -> (p:Program)
WHERE r.enroll_year > 1991
RETURN p.code, p.designation, r.enroll_year, count(r)
ORDER BY p.designation, r.enroll_year