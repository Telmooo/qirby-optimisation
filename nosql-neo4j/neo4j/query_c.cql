MATCH (s:Student) - [r:ENROLLED_IN] -> (p:Program)
MATCH (s) - [c:CANDIDATE_TO] -> (p)
WHERE c.average < r.final_average
RETURN s.id, r.nr