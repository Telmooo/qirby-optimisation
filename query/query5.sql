-- a - B-tree
CREATE INDEX BTREE_5 ON ZTIPOSAULA(ANO_LETIVO, TIPO);

SELECT CODIGO, ANO_LETIVO, PERIODO, SUM(COALESCE(N_AULAS, 1) * HORAS_TURNO * DECODE(PERIODO /*EXPR*/,
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
    FROM ZOCORRENCIAS
        INNER JOIN ZTIPOSAULA USING (CODIGO, ANO_LETIVO, PERIODO)
    WHERE TIPO = 'OT' AND (
        ANO_LETIVO = '2002/2003' OR ANO_LETIVO = '2003/2004'
    )
    GROUP BY (CODIGO, ANO_LETIVO, PERIODO);

DROP INDEX BTREE_5;

-- b - Bitmap
CREATE BITMAP INDEX BITMAP_5 ON ZTIPOSAULA(ANO_LETIVO, TIPO);

SELECT CODIGO, ANO_LETIVO, PERIODO, SUM(COALESCE(N_AULAS, 1) * HORAS_TURNO * DECODE(PERIODO /*EXPR*/,
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
    FROM ZOCORRENCIAS
        INNER JOIN ZTIPOSAULA USING (CODIGO, ANO_LETIVO, PERIODO)
    WHERE TIPO = 'OT' AND (
        ANO_LETIVO = '2002/2003' OR ANO_LETIVO = '2003/2004'
    )
    GROUP BY (CODIGO, ANO_LETIVO, PERIODO);

DROP INDEX BITMAP_5;