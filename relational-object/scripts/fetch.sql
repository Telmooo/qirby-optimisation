DECLARE
    nuts_1_ref REF nuts_1_t;
    nuts_2_ref REF nuts_2_t;
    nuts_3_ref REF nuts_3_t;
    municipality_ref REF municipality_t;
BEGIN
    FOR cur_rec IN (
        SELECT *
            FROM GTD12.municipalities m
            ORDER BY m.geolevel ASC
    )
    LOOP
        BEGIN
            CASE cur_rec.geolevel
                WHEN 0
                THEN
                    INSERT INTO countries c (code, designation, acronym, area, population, nuts_1)
                        VALUES (cur_rec.code, cur_rec.designation, cur_rec.acronym, cur_rec.area, cur_rec.population, nuts_1_tab());
                WHEN 1
                THEN
                    INSERT INTO nuts_1 n1 (code, designation, acronym, area, population, country, nuts_2)
                        VALUES (cur_rec.code, cur_rec.designation, cur_rec.acronym, cur_rec.area, cur_rec.population, (
                            SELECT REF(c)
                                FROM countries c
                                WHERE c.code = cur_rec.parent
                        ), nuts_2_tab()) RETURNING REF(n1) into nuts_1_ref;

                    -- Manual Insert could be avoided with a trigger
                    INSERT INTO TABLE(
                        SELECT c.nuts_1
                            FROM countries c
                            WHERE c.code = cur_rec.parent
                    ) VALUES (nuts_1_ref);
                WHEN 2
                THEN
                    INSERT INTO nuts_2 n2 (code, designation, acronym, area, population, nuts_1, nuts_3)
                        VALUES (cur_rec.code, cur_rec.designation, cur_rec.acronym, cur_rec.area, cur_rec.population, (
                            SELECT REF(n1)
                                FROM nuts_1 n1
                                WHERE n1.code = cur_rec.parent
                        ), nuts_3_tab()) RETURNING REF(n2) into nuts_2_ref;

                    -- Manual Insert could be avoided with a trigger
                    INSERT INTO TABLE(
                        SELECT n1.nuts_2
                            FROM nuts_1 n1
                            WHERE n1.code = cur_rec.parent
                    ) VALUES (nuts_2_ref);
                WHEN 3
                THEN
                    INSERT INTO nuts_3 n3 (code, designation, acronym, area, population, nuts_2, municipalities)
                        VALUES (cur_rec.code, cur_rec.designation, cur_rec.acronym, cur_rec.area, cur_rec.population, (
                            SELECT REF(n2)
                                FROM nuts_2 n2
                                WHERE n2.code = cur_rec.parent
                        ), municipality_tab()) RETURNING REF(n3) into nuts_3_ref;

                    -- Manual Insert could be avoided with a trigger
                    INSERT INTO TABLE(
                        SELECT n2.nuts_3
                            FROM nuts_2 n2
                            WHERE n2.code = cur_rec.parent
                    ) VALUES (nuts_3_ref);
                ELSE
                    INSERT INTO municipalities m (code, designation, acronym, area, population, nuts_3, expenses, revenues)
                        VALUES (cur_rec.code, cur_rec.designation, cur_rec.acronym, cur_rec.area, cur_rec.population, (
                            SELECT REF(n3)
                                FROM nuts_3 n3
                                WHERE n3.code = cur_rec.parent
                        ), aremuneration_tab(), aremuneration_tab()) RETURNING REF(m) into municipality_ref;

                    -- Manual Insert could be avoided with a trigger
                    INSERT INTO TABLE(
                        SELECT n3.municipalities
                            FROM nuts_3 n3
                            WHERE n3.code = cur_rec.parent
                    ) VALUES (municipality_ref);
            END CASE;
        END;    
    END LOOP;
END;
/
-- Parties
INSERT INTO parties
SELECT p.acronym, p.partyName, p.spectrum
    FROM GTD12.parties p;
/
INSERT INTO periods (periodId, year, quarter, leaderships, expenses, revenues)
SELECT p.periodId, p.year, p.quarter, CAST(
        MULTISET(
            SELECT REF(m), REF(prt)
                FROM GTD12.leaderships l, municipalities m, parties prt
                WHERE l.periodId = p.periodId AND l.code = m.code AND prt.acronym = l.acronym
        ) AS leaderships_tab
    ), aremuneration_tab(), aremuneration_tab()
FROM GTD12.periods p;
/
-- Headings
DECLARE
    heading_ref     REF heading_t;
BEGIN
    FOR cur_rec IN (
        SELECT *
            FROM GTD12.headings h
            ORDER BY h.hlevel ASC
    )
    LOOP
        BEGIN
            CASE cur_rec.hlevel
            WHEN 1
            THEN
                INSERT INTO headings (headingId, description, remun_type, childHeadings, remunerations)
                    VALUES (cur_rec.headingId, cur_rec.description, cur_rec.type, headings_tab(), aremuneration_tab());
            ELSE
                INSERT INTO headings h (headingId, description, remun_type, parentHeading, childHeadings, remunerations)
                    VALUES (cur_rec.headingId, cur_rec.description, cur_rec.type, (
                        SELECT REF(hp)
                            FROM headings hp
                            WHERE hp.headingId = cur_rec.parent
                    ), headings_tab(), aremuneration_tab()) RETURNING REF(h) INTO heading_ref;

                INSERT INTO TABLE(
                    SELECT hp.childHeadings
                        FROM headings hp
                        WHERE hp.headingId = cur_rec.parent
                ) VALUES (heading_ref);
            END CASE;
        END;
    END LOOP;
END;
/
-- Remunerations
---- Expenses
DECLARE
    remuneration_ref    REF aremuneration_t;
BEGIN
    FOR cur_rec IN (
        SELECT *
            FROM GTD12.AEXPENSES 
    )
    LOOP
        BEGIN
            INSERT INTO expenses e (aremunerationId, amount, heading, code, period)
            VALUES (cur_rec.aexpensesId, cur_rec.amount, (
                SELECT REF(h)
                    FROM headings h
                    WHERE h.headingId = cur_rec.headingId
            ), (
                SELECT REF(m)
                    FROM municipalities m
                    WHERE m.code = cur_rec.code
            ), (
                SELECT REF(p)
                    FROM periods p
                    WHERE p.periodId = cur_rec.periodId
            )) RETURNING REF(e) INTO remuneration_ref;

            -- All following inserts could be avoided with triggers
            INSERT INTO TABLE(
                SELECT h.remunerations
                    FROM headings h
                    WHERE h.headingId = cur_rec.headingId
            ) VALUES (remuneration_ref);

            INSERT INTO TABLE(
                SELECT p.expenses
                    FROM periods p
                    WHERE p.periodId = cur_rec.periodId
            ) VALUES (remuneration_ref);

            INSERT INTO TABLE(
                SELECT m.expenses
                    FROM municipalities m
                    WHERE m.code = cur_rec.code
            ) VALUES (remuneration_ref);
        END;
    END LOOP;
END;
/
---- Revenues
DECLARE
    remuneration_ref    REF aremuneration_t;
BEGIN
    FOR cur_rec IN (
        SELECT *
            FROM GTD12.AREVENUES 
    )
    LOOP
        BEGIN
            INSERT INTO revenues r (aremunerationId, amount, heading, code, period)
            VALUES (cur_rec.arevenuesId, cur_rec.amount, (
                SELECT REF(h)
                    FROM headings h
                    WHERE h.headingId = cur_rec.headingId
            ), (
                SELECT REF(m)
                    FROM municipalities m
                    WHERE m.code = cur_rec.code
            ), (
                SELECT REF(p)
                    FROM periods p
                    WHERE p.periodId = cur_rec.periodId
            )) RETURNING REF(r) INTO remuneration_ref;

            -- All following inserts could be avoided with triggers
            INSERT INTO TABLE(
                SELECT h.remunerations
                    FROM headings h
                    WHERE h.headingId = cur_rec.headingId
            ) VALUES (remuneration_ref);

            INSERT INTO TABLE(
                SELECT p.revenues
                    FROM periods p
                    WHERE p.periodId = cur_rec.periodId
            ) VALUES (remuneration_ref);

            INSERT INTO TABLE(
                SELECT m.revenues
                    FROM municipalities m
                    WHERE m.code = cur_rec.code
            ) VALUES (remuneration_ref);
        END;
    END LOOP;
END;