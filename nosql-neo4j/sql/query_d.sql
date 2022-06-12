-- Find the average of the final grades of all the students finishing their program in
-- a certain number of years, 5 years, 6 years, ...
SELECT Students.conclusion_year - Students.enroll_year AS program_duration, avg(Students.final_average) FROM GTD12.Students Students
GROUP BY Students.conclusion_year - Students.enroll_year
ORDER BY program_duration;