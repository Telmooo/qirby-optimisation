-- Obtain the BI and the student number of the students with a final grade
-- (med_final) higher than the application grade (media).
SELECT Students.id, Students.nr FROM GTD12.Students Students
INNER JOIN GTD12.Candidates Candidates ON Students.id = Candidates.id and Students.program = Candidates.program and Students.enroll_year = Candidates.year
WHERE Students.final_average > Candidates.average;