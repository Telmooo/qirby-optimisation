-- NUTS
---- Base Types
CREATE OR REPLACE TYPE nuts_t AS OBJECT(
    code            VARCHAR2(10),
    designation     VARCHAR2(255),
    acronym         VARCHAR2(10),
    area            NUMBER(38, 0),
    population      NUMBER(38, 0)
) NOT INSTANTIABLE NOT FINAL;
/
CREATE OR REPLACE TYPE country_t UNDER nuts_t (

);
/
CREATE OR REPLACE TYPE nuts_1_t UNDER nuts_t (
    country REF country_t
);
/
CREATE OR REPLACE TYPE nuts_2_t UNDER nuts_t (
    nuts_1 REF nuts_1_t
);
/
CREATE OR REPLACE TYPE nuts_3_t UNDER nuts_t (
    nuts_2 REF nuts_2_t
);
/
CREATE OR REPLACE TYPE municipality_t UNDER nuts_t (
    nuts_3 REF nuts_3_t
);
/
---- Table Types
CREATE OR REPLACE TYPE municipality_tab AS TABLE OF REF municipality_t;
/
CREATE OR REPLACE TYPE nuts_3_tab AS TABLE OF REF nuts_3_t;
/
CREATE OR REPLACE TYPE nuts_2_tab AS TABLE OF REF nuts_2_t;
/
CREATE OR REPLACE TYPE nuts_1_tab AS TABLE OF REF nuts_1_t;
/
---- Add nested tables onto base types
ALTER TYPE nuts_3_t ADD ATTRIBUTE (municipalities municipality_tab) CASCADE;
/
ALTER TYPE nuts_2_t ADD ATTRIBUTE (nuts_3 nuts_3_tab) CASCADE;
/
ALTER TYPE nuts_1_t ADD ATTRIBUTE (nuts_2 nuts_2_tab) CASCADE;
/
ALTER TYPE country_t ADD ATTRIBUTE (nuts_1 nuts_1_tab) CASCADE;
/
-- PARTIES
CREATE OR REPLACE TYPE party_t AS OBJECT (
    acronym     VARCHAR2(26),
    partyName   VARCHAR2(26),
    spectrum    VARCHAR2(20)
);
/
-- PERIODS
CREATE OR REPLACE TYPE leadership_t AS OBJECT (
    code REF municipality_t,
    party REF party_t
);
/
CREATE OR REPlACE TYPE leaderships_tab AS TABLE OF leadership_t;
/
CREATE OR REPLACE TYPE period_t AS OBJECT (
    periodId        NUMBER(38, 0),
    year            NUMBER(38, 0),
    quarter         NUMBER(38, 0),
    leaderships     leaderships_tab,

    MEMBER FUNCTION remunerations_km2(heading_name VARCHAR2, party_name VARCHAR2, municipality_code VARCHAR2) RETURN NUMBER,
    MEMBER FUNCTION remunerations_1k_people(heading_name VARCHAR2, party_name VARCHAR2, municipality_code VARCHAR2) RETURN NUMBER
);
/
-- HEADINGS
CREATE OR REPLACE TYPE heading_t AS OBJECT (
    headingId       NUMBER(38, 0),
    description     VARCHAR2(128),
    remun_type      VARCHAR2(1),
    MEMBER FUNCTION get_value RETURN NUMBER,
    MEMBER FUNCTION is_consistent RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE headings_tab AS TABLE OF REF heading_t;
/
ALTER TYPE heading_t ADD ATTRIBUTE (parentHeading REF heading_t, childHeadings headings_tab) CASCADE;
/
-- REMUNERATIONS
CREATE OR REPLACE TYPE aremuneration_t AS OBJECT (
    aremunerationId     NUMBER(38, 0),
    amount              NUMBER(38, 2),
    heading             REF heading_t,
    code                REF municipality_t,
    period              REF period_t
);
/
CREATE OR REPLACE TYPE aremuneration_tab AS TABLE OF REF aremuneration_t;
/
-- Backwards addition of remunerations tables
ALTER TYPE heading_t ADD ATTRIBUTE (remunerations aremuneration_tab) CASCADE;
/
ALTER TYPE period_t ADD ATTRIBUTE (expenses aremuneration_tab, revenues aremuneration_tab) CASCADE;
/
ALTER TYPE municipality_t ADD ATTRIBUTE (expenses aremuneration_tab, revenues aremuneration_tab) CASCADE;
/
-- METHODS
CREATE OR REPLACE TYPE BODY heading_t AS
    MEMBER FUNCTION get_value RETURN NUMBER IS
        res NUMBER;
    BEGIN
        SELECT SUM(VALUE(r).amount) INTO res FROM TABLE(SELF.remunerations) r;
        IF remun_type = 'D' THEN
            RETURN -res;
        ELSE
            RETURN res;
        END IF;
    END get_value;

    MEMBER FUNCTION is_consistent RETURN VARCHAR2 IS
        child_sum NUMBER;
    BEGIN
        SELECT SUM(VALUE(h).get_value()) INTO child_sum FROM TABLE(SELF.childHeadings) h;
        child_sum := NVL(child_sum, -1);
        IF child_sum = -1 OR SELF.get_value() = child_sum THEN
            RETURN 'T';
        ELSE
            RETURN 'F';
        END IF;
    END is_consistent;
END;
/
CREATE OR REPLACE TYPE BODY period_t AS
    MEMBER FUNCTION remunerations_km2(heading_name VARCHAR2, party_name VARCHAR2, municipality_code VARCHAR2) RETURN NUMBER IS
        ret_var NUMBER;
    BEGIN
        SELECT SUM(VALUE(e).amount) / MAX(VALUE(l).code.area) INTO ret_var
            FROM TABLE(SELF.expenses) e, TABLE(SELF.leaderships) l
            WHERE VALUE(e).heading.description = heading_name
                AND VALUE(e).code.code = municipality_code
                AND VALUE(l).party.acronym = party_name
                AND VALUE(l).code.code = municipality_code;
        ret_var := NVL(ret_var, 0);
        RETURN ret_var;
    END;

    MEMBER FUNCTION remunerations_1k_people(heading_name VARCHAR2, party_name VARCHAR2, municipality_code VARCHAR2) RETURN NUMBER IS
        ret_var NUMBER;
    BEGIN
        SELECT SUM(VALUE(e).amount) / MAX(VALUE(l).code.population) * 1000 INTO ret_var
            FROM TABLE(SELF.expenses) e, TABLE(SELF.leaderships) l
            WHERE VALUE(e).heading.description = heading_name
                AND VALUE(e).code.code = municipality_code
                AND VALUE(l).party.acronym = party_name
                AND VALUE(l).code.code = municipality_code;
        ret_var := NVL(ret_var, 0);
        RETURN ret_var;
    END;
END;
/

-- TABLE CREATION
CREATE TABLE countries OF country_t (
    code            PRIMARY KEY
)
    NESTED TABLE nuts_1 STORE AS nuts_1_nt;
/
CREATE TABLE nuts_1 OF nuts_1_t (
    code            PRIMARY KEY
)
    NESTED TABLE nuts_2 STORE AS nuts_2_nt;
/
CREATE TABLE nuts_2 OF nuts_2_t (
    code            PRIMARY KEY
)
    NESTED TABLE nuts_3 STORE AS nuts_3_nt;
/
CREATE TABLE nuts_3 OF nuts_3_t (
    code            PRIMARY KEY
)
    NESTED TABLE municipalities STORE AS municipalities_nt;
/
CREATE TABLE municipalities OF municipality_t (
    code            PRIMARY KEY
)
    NESTED TABLE expenses STORE AS municipalities_expenses_nt
    NESTED TABLE revenues STORE AS municipalities_revenues_nt;
/
CREATE TABLE parties OF party_t (
    acronym     PRIMARY KEY
);
/
CREATE TABLE periods OF period_t (
    periodId    PRIMARY KEY
)
    NESTED TABLE leaderships STORE AS leadership_nt
    NESTED TABLE expenses STORE AS period_expenses_nt
    NESTED TABLE revenues STORE AS period_revenues_nt;
/
CREATE TABLE expenses OF aremuneration_t (
    aremunerationId     PRIMARY KEY
);
/
CREATE TABLE revenues OF aremuneration_t (
    aremunerationId     PRIMARY KEY
);
/
CREATE TABLE headings OF heading_t (
    headingId       PRIMARY KEY
)
    NESTED TABLE childHeadings STORE AS heading_children_nt
    NESTED TABLE remunerations STORE AS heading_remunerations_nt;
