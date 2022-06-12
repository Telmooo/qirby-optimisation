-- The students that applied multiple times to the same program
SELECT Students.id, Programs.code, Programs.designation, count(Candidates.year) AS applications_per_student FROM GTD12.Students Students
INNER JOIN GTD12.Candidates Candidates ON Students.id = Candidates.id and Students.program = Candidates.program
INNER JOIN GTD12.Programs Programs ON Candidates.program = Programs.code
GROUP BY Students.id, Candidates.program, Programs.code, Programs.designation
HAVING count(Candidates.year) > 1
ORDER BY applications_per_student DESC;