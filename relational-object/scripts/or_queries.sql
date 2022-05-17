-- Calculate the expenses by period and by heading of the municipalities of each region.
-- Order municipalities by decreasing population.
SELECT m.designation, VALUE(e).period.year year, VALUE(e).heading.description description, m.population, SUM(VALUE(e).amount) total_amount
FROM municipalities m, TABLE(m.expenses) e
GROUP BY VALUE(e).period.year, VALUE(e).heading.description, m.designation, m.population
ORDER BY m.population DESC;

-- Check whether the higher level headings values are consistent with the corresponding lower values.
SELECT h.description, h.is_consistent() FROM headings h;


-- Which is the average expense by thousand inhabitants on each heading for each party?
WITH aux_view (partyName, description, remun) AS (
    SELECT VALUE(l).party.partyName partyName, h.description, SUM(p.remunerations_1k_people(h.description, VALUE(l).party.acronym, VALUE(l).code.code)) 
    FROM periods p, TABLE(p.leaderships) l, headings h
    GROUP BY VALUE(l).party.partyName, h.description
)
SELECT partyName, description, AVG(remun)
FROM aux_view v
GROUP BY partyName, description
ORDER BY partyName, description;


-- Which is the party with more investment per square km on each year?
WITH aux_view (partyName, year, remun_km2) AS (
    SELECT VALUE(l).party.partyName partyName, p.year, SUM(p.remunerations_km2('INVESTIMENTOS', VALUE(l).party.acronym, VALUE(l).code.code)) 
    FROM periods p, TABLE(p.leaderships) l
    GROUP BY VALUE(l).party.partyName, p.year
)
SELECT partyName, year, remun_km2
FROM aux_view v
WHERE (v.year, v.remun_km2) IN (
    SELECT vmax.year, MAX(vmax.remun_km2)
            FROM aux_view vmax
            GROUP BY vmax.year
)
ORDER BY year;


-- Which is the party with more salaries per thousand inhabitants on each year?
WITH aux_view (partyName, year, remun_1k) AS (
    SELECT VALUE(l).party.partyName partyName, p.year, SUM(p.remunerations_1k_people('DESPESA_COM_PESSOAL', VALUE(l).party.acronym, VALUE(l).code.code)) 
    FROM periods p, TABLE(p.leaderships) l
    GROUP BY VALUE(l).party.partyName, p.year
)
SELECT partyName, year, remun_1k
FROM aux_view v
WHERE (v.year, v.remun_1k) IN (
    SELECT vmax.year, MAX(vmax.remun_1k)
            FROM aux_view vmax
            GROUP BY vmax.year
)
ORDER BY year;

-- Add a query that illustrates the use of OR extensions
-- Profit of each NUTS III for each year
SELECT n3.designation, VALUE(e).period.year AS year, SUM(VALUE(r).amount) - SUM(VALUE(e).amount) AS profit
    FROM nuts_3 n3, TABLE(n3.municipalities) m, TABLE(VALUE(m).expenses) e, TABLE(VALUE(m).revenues) r
    WHERE VALUE(e).heading.description = 'DESPESA_TOTAL' AND VALUE(r).heading.description = 'RECEITAS_TOTAIS'
        AND VALUE(e).period.year = VALUE(r).period.year
    GROUP BY n3.designation, VALUE(e).period.year;