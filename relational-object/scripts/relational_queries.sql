-- Calculate the expenses by period and by heading of the municipalities of each region.
-- Order municipalities by decreasing population.
SELECT m.nuts_3, m.m_designation AS municipality, p.year, h.description, m.m_population, SUM(e.amount) AS TOTAL_AMOUNT
    FROM GTD12.aexpenses e
        INNER JOIN GTD12.periods p ON e.periodId = p.periodId
        INNER JOIN GTD12.headings h ON h.headingId = e.headingId
        INNER JOIN (
            SELECT n3.designation AS nuts_3, m.code AS m_code, m.designation AS m_designation, m.population AS m_population
                FROM GTD12.municipalities m
                    INNER JOIN GTD12.municipalities n3 ON m.parent = n3.code
                WHERE m.geolevel = 4
        ) m ON m.m_code = e.code
    GROUP BY m.nuts_3, m.m_designation, p.year, h.description, m.m_population
    ORDER BY m.m_population DESC;

-- Check whether the higher level headings values are consistent with the corresponding lower values.
WITH aux_view (description, hlevel, total_amount, total_child_amount) AS (
    SELECT h.description, h.hlevel, SUM(COALESCE(e.amount, r.amount)) AS total_amount, COALESCE((
        SELECT SUM(COALESCE(ce.amount, cr.amount)) AS total_child_amount
                    FROM GTD12.headings ch
                        LEFT OUTER JOIN GTD12.aexpenses ce ON ch.headingId = ce.headingId
                        LEFT OUTER JOIN GTD12.arevenues cr ON ch.headingId = cr.headingId
                    WHERE ch.parent = h.headingId
                    GROUP BY ch.parent
    ), -1) AS total_child_amount
        FROM GTD12.headings h
            LEFT OUTER JOIN GTD12.aexpenses e ON h.headingId = e.headingId
            LEFT OUTER JOIN GTD12.arevenues r ON h.headingId = r.headingId
        GROUP BY h.headingId, h.description, h.hlevel
)
SELECT v.description, v.hlevel, v.total_amount, v.total_child_amount, (
    CASE
    WHEN v.total_amount = v.total_child_amount THEN 'TRUE'
    WHEN v.total_child_amount = -1 THEN 'TRUE'
    ELSE 'FALSE'
    END
) AS consistent
FROM aux_view v;

-- Which the average expense by thousand inhabitants on each heading for each party?
WITH aux_view (headingId, description, partyName, code, expense_by_thousand_inhabitants) AS (
    SELECT h.headingId, h.description, prt.partyName, m.code, SUM(e.amount) * 1000 / m.population AS expense_by_thousand_inhabitants
        FROM GTD12.headings h
            INNER JOIN GTD12.aexpenses e ON h.headingId = e.headingId
            INNER JOIN GTD12.municipalities m ON m.code = e.code
            INNER JOIN GTD12.periods p ON p.periodId = e.periodId
            INNER JOIN GTD12.leaderships l ON (l.code = m.code AND l.periodId = p.periodId)
            INNER JOIN GTD12.parties prt ON prt.acronym = l.acronym
        GROUP BY h.headingId, h.description, prt.partyName, m.code, m.population
)
SELECT v.headingId, v.description, v.partyName, AVG(v.expense_by_thousand_inhabitants) AS avg_expense_by_thousand_inhabitants
    FROM aux_view v
    GROUP BY v.headingId, v.description, v.partyName;

-- Which is the party with more investment per square km on each year?
WITH aux_view (description, partyName, year, investment_per_km2) AS (
    SELECT h.description, prt.partyName, p.year, SUM(e.amount) / SUM(m.area) AS investment_per_km2
        FROM GTD12.headings h
            INNER JOIN GTD12.aexpenses e ON h.headingId = e.headingId
            INNER JOIN GTD12.municipalities m ON m.code = e.code
            INNER JOIN GTD12.periods p ON p.periodId = e.periodId
            INNER JOIN GTD12.leaderships l ON (l.code = m.code AND l.periodId = p.periodId)
            INNER JOIN GTD12.parties prt ON prt.acronym = l.acronym
        WHERE h.description = 'INVESTIMENTOS'
        GROUP BY h.headingId, h.description, prt.partyName, p.year
)
SELECT v.description, v.partyName, v.year, v.investment_per_km2
    FROM aux_view v
    WHERE (v.year, v.investment_per_km2) IN (
        SELECT vmax.year, MAX(vmax.investment_per_km2)
            FROM aux_view vmax
            GROUP BY vmax.year
    );

-- Which is the party with more salaries per thousand inhabitants on each year?
WITH aux_view (description, partyName, year, salaries_per_thousand_inhabitants) AS (
    SELECT h.description, prt.partyName, p.year, SUM(e.amount) * 1000 / SUM(m.population) AS salaries_per_thousand_inhabitants
        FROM GTD12.headings h
            INNER JOIN GTD12.aexpenses e ON h.headingId = e.headingId
            INNER JOIN GTD12.municipalities m ON m.code = e.code
            INNER JOIN GTD12.periods p ON p.periodId = e.periodId
            INNER JOIN GTD12.leaderships l ON (l.code = m.code AND l.periodId = p.periodId)
            INNER JOIN GTD12.parties prt ON prt.acronym = l.acronym
        WHERE h.description = 'DESPESA_COM_PESSOAL'
        GROUP BY h.headingId, h.description, prt.partyName, p.year
)
SELECT v.description, v.partyName, v.year, v.salaries_per_thousand_inhabitants
    FROM aux_view v
    WHERE (v.year, v.salaries_per_thousand_inhabitants) IN (
        SELECT vmax.year, MAX(vmax.salaries_per_thousand_inhabitants)
            FROM aux_view vmax
            GROUP BY vmax.year
    );