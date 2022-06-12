-- Calculate the total number of students enrolled in each program, in each year, after 1991
SELECT Programs.code, Programs.designation, Students.enroll_year, count(Students.nr) FROM GTD12.Students Students
INNER JOIN GTD12.Programs Programs ON Students.program = Programs.code
WHERE Students.enroll_year > 1991
GROUP BY Programs.code, Programs.designation, Students.enroll_year
ORDER BY Programs.designation, Students.enroll_year;