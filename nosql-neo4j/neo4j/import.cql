MATCH (x) DETACH DELETE x;

CREATE INDEX IF NOT EXISTS FOR (p:Program) ON (p.code);
CREATE INDEX IF NOT EXISTS FOR (p:Person) ON (p.id);
CREATE INDEX IF NOT EXISTS FOR (s:Student) ON (s.nr);

LOAD CSV WITH HEADERS FROM 'file:///year.csv' AS line
CREATE (:Year { year: toInteger(line.YEAR) });

LOAD CSV WITH HEADERS FROM 'file:///programs.csv' AS line
CREATE ( :Program {
    code: toInteger(line.CODE),
    acronym: line.ACRONYM,
    designation: line.DESIGNATION
});

LOAD CSV WITH HEADERS FROM 'file:///candidates.csv' AS line
MATCH (prog:Program {code: toInteger(line.PROGRAM)})
MERGE (candidate:Person  { id: toInteger(line.ID) })
CREATE (candidate) - [:CANDIDATE_TO {
        year: toInteger(line.YEAR),
        result: line.RESULT,
        average: toFloat(line.AVERAGE)
    }] -> (prog);

LOAD CSV WITH HEADERS FROM 'file:///students.csv' AS line
MATCH (s:Person {id: toInteger(line.ID)} )
MATCH (prog: Program { code: toInteger(line.PROGRAM) } )
SET s:Student
CREATE (s) - [:ENROLLED_IN {
    nr: toInteger(line.NR),
    enroll_year: toInteger(line.ENROLL_YEAR),
    status: line.STATUS,
    conclusion_year: toInteger(line.CONCLUSION_YEAR),
    final_average: toFloat(line.FINAL_AVERAGE)
} ] -> (prog);
