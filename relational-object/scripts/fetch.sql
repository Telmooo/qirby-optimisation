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
