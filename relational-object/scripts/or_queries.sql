SELECT 'INVESTIMENTOS', VALUE(l).party.acronym, p.year, VALUE(l).code.code, p.remunerations_km2('INVESTIMENTOS', VALUE(l).party.acronym, VALUE(l).code.code) 
    FROM periods p, TABLE(p.leaderships) l;