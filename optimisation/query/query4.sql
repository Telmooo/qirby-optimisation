-- X-environment
WITH AUX (NR, NOME, TIPO, HOURS) AS (
    SELECT NR, NOME, TIPO,
            SUM(HORAS * DECODE(PERIODO /*EXPR*/,
                    '1S', 6, /*SEARCH, RESULT*/
                    '2S', 6,
                    '1T', 3,
                    '2T', 3,
                    '3T', 3,
                    '4T', 3,
                    'T', 3,
                    'A', 12,
                    'B', 2,
                    6 /*DEFAULT*/) * 4) AS HOURS
        FROM XDOCENTES
            INNER JOIN XDSD USING(NR)
            INNER JOIN XTIPOSAULA USING(ID)
            INNER JOIN XOCORRENCIAS USING(CODIGO, ANO_LETIVO, PERIODO)
        WHERE ANO_LETIVO = '2003/2004'
        GROUP BY (TIPO, NR, NOME)
)
SELECT NR, NOME, TIPO, HOURS
    FROM AUX
        INNER JOIN (
            SELECT TIPO, MAX(HOURS) AS HOURS
                FROM AUX
                GROUP BY TIPO
        ) USING (TIPO, HOURS);

-- Y-environment
WITH AUX (NR, NOME, TIPO, HOURS) AS (
    SELECT NR, NOME, TIPO,
            SUM(HORAS * DECODE(PERIODO /*EXPR*/,
                    '1S', 6, /*SEARCH, RESULT*/
                    '2S', 6,
                    '1T', 3,
                    '2T', 3,
                    '3T', 3,
                    '4T', 3,
                    'T', 3,
                    'A', 12,
                    'B', 2,
                    6 /*DEFAULT*/) * 4) AS HOURS
        FROM YDOCENTES
            INNER JOIN YDSD USING(NR)
            INNER JOIN YTIPOSAULA USING(ID)
            INNER JOIN YOCORRENCIAS USING(CODIGO, ANO_LETIVO, PERIODO)
        WHERE ANO_LETIVO = '2003/2004'
        GROUP BY (TIPO, NR, NOME)
)
SELECT NR, NOME, TIPO, HOURS
    FROM AUX
        INNER JOIN (
            SELECT TIPO, MAX(HOURS) AS HOURS
                FROM AUX
                GROUP BY TIPO
        ) USING (TIPO, HOURS);

-- Z-environment
WITH AUX (NR, NOME, TIPO, HOURS) AS (
    SELECT NR, NOME, TIPO,
            SUM(HORAS * DECODE(PERIODO /*EXPR*/,
                    '1S', 6, /*SEARCH, RESULT*/
                    '2S', 6,
                    '1T', 3,
                    '2T', 3,
                    '3T', 3,
                    '4T', 3,
                    'T', 3,
                    'A', 12,
                    'B', 2,
                    6 /*DEFAULT*/) * 4) AS HOURS
        FROM ZDOCENTES
            INNER JOIN ZDSD USING(NR)
            INNER JOIN ZTIPOSAULA USING(ID)
            INNER JOIN ZOCORRENCIAS USING(CODIGO, ANO_LETIVO, PERIODO)
        WHERE ANO_LETIVO = '2003/2004'
        GROUP BY (TIPO, NR, NOME)
)
SELECT NR, NOME, TIPO, HOURS
    FROM AUX
        INNER JOIN (
            SELECT TIPO, MAX(HOURS) AS HOURS
                FROM AUX
                GROUP BY TIPO
        ) USING (TIPO, HOURS);