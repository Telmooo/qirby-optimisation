-- Obtain the name of the program where the candidate 12147897 was enrolled
SELECT Programs.designation FROM GTD12.Students Students
INNER JOIN GTD12.Programs Programs ON Students.program = Programs.code
WHERE Students.id = 12147897;