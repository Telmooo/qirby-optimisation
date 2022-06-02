MATCH (:Person{id: 12147897 }) - [:CANDIDATE_TO] -> (p:Program)
RETURN p.designation;